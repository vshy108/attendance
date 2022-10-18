module PunchTimeHandler
  include RepeatTemplateHandler
  include WorkingTemplateHandler

  FIRST_CHECK_IN_TOLERANCE_IN_MINS = 120

  def waiting_process_objects
    pt = PunchTime.arel_table
    PunchTime.where(pt[:working_day_id].eq(nil).and(pt[:uncertain_working_day_id].eq(nil)))
  end

  def waiting_process_count
    waiting_process_objects.count
  end

  def waiting_process_ids
    pt = PunchTime.arel_table
    waiting_process_objects.pluck(pt[:id])
  end

  def convert_to_total_mins(punched_datetime, referring_date)
    day_difference = (punched_datetime.to_date - referring_date.to_date).to_i
    h = punched_datetime.strftime('%H').to_i
    m = punched_datetime.strftime('%M').to_i
    day_difference * 24 * 60 + h * 60 + m
  end

  def create_working_day_and_assign(punch_time, working_date, working_template)
    working_day = punch_time.worker.working_days.create(working_date: working_date, working_template: working_template)
    punch_time.working_day = working_day
    punch_time.uncertain_working_day = nil
    punch_time.save
  end

  def create_uncertain_working_day_and_assign(punch_time, working_date, working_template)
    working_day = punch_time.worker.working_days.create(working_date: working_date, working_template: working_template)
    punch_time.uncertain_working_day = working_day
    punch_time.working_day = nil
    punch_time.save
  end

  def save_working_day(punch_time, working_day)
    punch_time.working_day = working_day
    punch_time.uncertain_working_day = nil
    punch_time.save
  end

  def save_uncertain_working_day(punch_time, working_day)
    punch_time.uncertain_working_day = working_day
    punch_time.working_day = nil
    punch_time.save
  end

  def check_under_absolute_range(offset_first_from, offset_last_to, punch_time_value)
    (offset_first_from <= punch_time_value) && (offset_last_to >= punch_time_value)
  end

  def check_working_day(input)
    punch_time_value = input[:punch_time_value]
    offset_mins = input[:offset_mins]
    working_date = input[:working_date]
    worker = input[:worker]
    working_day = WorkingDay.where(working_date: working_date, worker: worker).lazy.first.presence
    if working_day.nil?
      if input[:repeat_template_first_from].present?
        first_from = input[:repeat_template_first_from]
        last_to = input[:repeat_template_last_to]
      else
        first_from = input[:default_template_first_from]
        last_to = input[:default_template_last_to]
      end
    else
      working_template = working_day.working_template
      first_from = working_template.valid_work_sections.pluck(:from_time_in_minute).min
      return { error: "Missing valid working section of existing template with id #{working_template.id}" } if first_from.nil?

      last_to = working_template.valid_work_sections.pluck(:to_time_in_minute).max
    end
    offset_first_from = first_from + offset_mins
    offset_last_to = last_to + offset_mins
    is_under_absolute_range = check_under_absolute_range(offset_first_from, offset_last_to, punch_time_value)
    {
      working_day: working_day,
      is_under_absolute_range: is_under_absolute_range,
      first_from: first_from,
      last_to: last_to,
      offset_first_from: offset_first_from,
      offset_last_to: offset_last_to
    }
  end

  def handle_under_absolute_range(working_day, punch_time, punch_time_date, repeat_default_working_template)
    if working_day.presence
      save_working_day(punch_time, working_day)
    else
      create_working_day_and_assign(punch_time, punch_time_date, repeat_default_working_template)
    end
  end

  def handle_under_uncertain_range(working_day, punch_time, punch_time_date, repeat_default_working_template)
    if working_day.presence
      save_uncertain_working_day(punch_time, working_day)
    else
      create_uncertain_working_day_and_assign(punch_time, punch_time_date, repeat_default_working_template)
    end
    nil
  end

  # both offsets are refer to punch_time_date
  def generate_working_day_uncertain_min(punch_time_date, earlier_working_day, earlier_offset_last_to, working_day, offset_first_from)
    gap = offset_first_from - earlier_offset_last_to
    half_gap = gap / 2.0
    # tolerance might have half of a minute
    tolerance = [ half_gap, FIRST_CHECK_IN_TOLERANCE_IN_MINS ].min
    # give offset_first_from if got extra 1 min, hence use floor
    earlier_offset_last_to_with_tolerance_datetime = punch_time_date.beginning_of_day + earlier_offset_last_to.minutes + tolerance.floor.minutes
    earlier_working_day_uncertain_max_datetime = earlier_offset_last_to_with_tolerance_datetime
    if earlier_working_day.presence && earlier_working_day.uncertain_punch_times.any?
      earlier_working_day_uncertain_sections_max = earlier_working_day.uncertain_punch_times.pluck(:punched_datetime).max
      if earlier_working_day_uncertain_sections_max > earlier_working_day_uncertain_max_datetime
        earlier_working_day_uncertain_max_datetime = earlier_working_day_uncertain_sections_max
        # NOTE: make the uncertain punchtime of working_day fall into the extended gap belongs to earlier_working_day
        if working_day.presence && working_day.uncertain_punch_times.any?
          pt = PunchTime.arel_table
          waiting_change_uncertain_punch_times = working_day.uncertain_punch_times.where(
            pt[:punched_datetime].lteq(earlier_working_day_uncertain_sections_max).and(
              pt[:punched_datetime].gteq(earlier_working_day_uncertain_max_datetime)
            )
          )
          if waiting_change_uncertain_punch_times.any?
            waiting_change_uncertain_punch_times.each do |wcupt|
              wcupt.uncertain_working_day = earlier_working_day
              wcupt.save
            end
          end
        end
      end
    end
    if earlier_working_day_uncertain_max_datetime == earlier_offset_last_to_with_tolerance_datetime
      earlier_offset_last_to_with_tolerance_datetime = punch_time_date.beginning_of_day + offset_first_from.minutes - tolerance.ceil.minutes
      working_day_uncertain_min_datetime = earlier_offset_last_to_with_tolerance_datetime
      if working_day.presence && working_day.uncertain_punch_times.any?
        working_day_uncertain_sections_min = working_day.uncertain_punch_times.pluck(:punched_datetime).min
        working_day_uncertain_min_datetime = working_day_uncertain_sections_min if working_day_uncertain_sections_min < working_day_uncertain_min_datetime
      end
      working_day_uncertain_min_datetime # final_working_day_uncertain_min
    else
      earlier_working_day_uncertain_max_datetime + 1.minute # final_working_day_uncertain_min
    end
  end

  def assign_working_day(punch_time_id)
    # return if worker no default template
    punch_time = PunchTime.find_by(id: punch_time_id)
    return { error: 'Invalid punch time' } if punch_time.nil?
    # silence this error because it might be caused by generate_working_day_uncertain_min
    return if !punch_time.working_day_id.nil? || !punch_time.uncertain_working_day_id.nil?

    # return if worker no default template
    worker = punch_time.worker
    default_template = worker.default_template.presence
    return { error: 'Missing default template' } if default_template.nil?

    # get the default template range in minutes
    default_working_template = default_template.working_template
    default_template_first_from = default_working_template.valid_work_sections.pluck(:from_time_in_minute).min
    return { error: 'Missing valid working section of default template' } if default_template_first_from.nil?

    default_template_last_to = default_working_template.valid_work_sections.pluck(:to_time_in_minute).max

    punched_datetime = punch_time.punched_datetime
    punch_time_date = punched_datetime&.to_date
    # get the total minutes of the punch time
    punch_time_value = convert_to_total_mins(punched_datetime, punch_time_date)

    today_working_template_of_repeat_template = obtain_working_template_of_repeat_template(worker, punch_time_date)
    if today_working_template_of_repeat_template.present?
      repeat_template_first_from = obtain_working_template_first_from(today_working_template_of_repeat_template)
      repeat_template_last_to = obtain_working_template_last_to(today_working_template_of_repeat_template)
    end
    today_checking_output = check_working_day(
      punch_time_value: punch_time_value,
      offset_mins: 0,
      working_date: punch_time_date,
      default_template_first_from: default_template_first_from,
      default_template_last_to: default_template_last_to,
      repeat_template_first_from: repeat_template_first_from,
      repeat_template_last_to: repeat_template_last_to,
      worker: worker
    )
    return today_checking_output[:error] if today_checking_output[:error].presence

    if today_checking_output[:is_under_absolute_range]
      handle_under_absolute_range(
        today_checking_output[:working_day],
        punch_time, punch_time_date,
        today_working_template_of_repeat_template || default_working_template,
      )
      return
    end
    one_day_minutes = 24 * 60
    if punch_time_value < today_checking_output[:first_from]
      yesterday_working_template_of_repeat_template = obtain_working_template_of_repeat_template(worker, punch_time_date - 1.day)
      if yesterday_working_template_of_repeat_template.present?
        yesterday_repeat_template_first_from = obtain_working_template_first_from(yesterday_working_template_of_repeat_template)
        yesterday_repeat_template_last_to = obtain_working_template_last_to(yesterday_working_template_of_repeat_template)
      end
      yesterday_checking_output = check_working_day(
        punch_time_value: punch_time_value,
        offset_mins: -one_day_minutes,
        working_date: punch_time_date - 1.day,
        default_template_first_from: default_template_first_from,
        default_template_last_to: default_template_last_to,
        repeat_template_first_from: yesterday_repeat_template_first_from,
        repeat_template_last_to: yesterday_repeat_template_last_to,
        worker: worker
      )
      return yesterday_checking_output[:error] if yesterday_checking_output[:error].presence

      if yesterday_checking_output[:is_under_absolute_range]
        handle_under_absolute_range(
          yesterday_checking_output[:working_day],
          punch_time, punch_time_date - 1.day,
          yesterday_working_template_of_repeat_template || default_working_template,
        )
        return
      else
        today_uncertain_min_datetime = generate_working_day_uncertain_min(punch_time_date, yesterday_checking_output[:working_day], yesterday_checking_output[:offset_last_to], today_checking_output[:working_day], today_checking_output[:offset_first_from])
        if punched_datetime < today_uncertain_min_datetime
          handle_under_uncertain_range(yesterday_checking_output[:working_day], punch_time, punch_time_date - 1.day, yesterday_working_template_of_repeat_template || default_working_template)
        else
          handle_under_uncertain_range(today_checking_output[:working_day], punch_time, punch_time_date, today_working_template_of_repeat_template || default_working_template)
        end
        return
      end
    else
      tomorrow_working_template_of_repeat_template = obtain_working_template_of_repeat_template(worker, punch_time_date + 1.day)
      if tomorrow_working_template_of_repeat_template.present?
        tomorrow_repeat_template_first_from = obtain_working_template_first_from(tomorrow_working_template_of_repeat_template)
        tomorrow_repeat_template_last_to = obtain_working_template_last_to(tomorrow_working_template_of_repeat_template)
      end
      tomorrow_checking_output = check_working_day(
        punch_time_value: punch_time_value,
        offset_mins: +one_day_minutes,
        working_date: punch_time_date + 1.day,
        default_template_first_from: default_template_first_from,
        default_template_last_to: default_template_last_to,
        repeat_template_first_from: tomorrow_repeat_template_first_from,
        repeat_template_last_to: tomorrow_repeat_template_last_to,
        worker: worker
      )
      return tomorrow_checking_output[:error] if tomorrow_checking_output[:error].presence

      if tomorrow_checking_output[:is_under_absolute_range]
        handle_under_absolute_range(
          tomorrow_checking_output[:working_day],
          punch_time, punch_time_date + 1.day,
          tomorrow_working_template_of_repeat_template || default_working_template,
        )
      else
        tomorrow_uncertain_min_datetime = generate_working_day_uncertain_min(punch_time_date, today_checking_output[:working_day], today_checking_output[:offset_last_to], tomorrow_checking_output[:working_day], tomorrow_checking_output[:offset_first_from])
        if punched_datetime < tomorrow_uncertain_min_datetime
          handle_under_uncertain_range(today_checking_output[:working_day], punch_time, punch_time_date, today_working_template_of_repeat_template || default_working_template)
        else
          handle_under_uncertain_range(tomorrow_checking_output[:working_day], punch_time, punch_time_date + 1.day, tomorrow_working_template_of_repeat_template || default_working_template)
        end
      end
    end
  end

  def obtain_abnormal_working_days_hash
    wd = WorkingDay.arel_table
    pt = PunchTime.arel_table
    outerjoin = wd.join(pt, Arel::Nodes::RightOuterJoin).on(wd[:id].eq(pt[:working_day_id]).or(wd[:id].eq(pt[:uncertain_working_day_id]))).join_sources
    count_hash = WorkingDay.joins(outerjoin).select(wd[:id]).group(wd[:id]).count
    count_hash.select { |_, v| v.odd? }
  end

  def obtain_options_for_working_day_change(punch_datetime)
    punched_date = punch_datetime.punched_datetime.to_date
    current_day_string = punched_date.strftime('%F')
    options = if punch_datetime.punched_datetime < punched_date.noon
                [punched_date.yesterday.strftime('%F'), current_day_string]
              else # 12pm will never call this function
                [current_day_string, punched_date.tomorrow.strftime('%F')]
              end
    options
  end

  def worker_has_punch_times_within?(worker, current_datetime)
    pt = PunchTime.arel_table
    not_allowed_range = Setting.min_punch_diff_minutes
    max_not_allowed_min = (current_datetime + not_allowed_range.minutes)
    min_not_allowed_min = (current_datetime - not_allowed_range.minutes)
    worker.punch_times.where(
      pt[:punched_datetime].lt(max_not_allowed_min).and(
        pt[:punched_datetime].gt(min_not_allowed_min)
      )
    ).any?
  end
end
