class DailyReportCreator < ApplicationService
  attr_reader :start_date
  attr_reader :worker
  include PunchTimeHandler
  include TimeHandler
  include RangeHandler

  def initialize(worker, start_date)
    @worker = worker
    @start_date = start_date
  end

  def call
    working_day = @worker.working_days.find_by(working_date: @start_date)
    if working_day
      # TODO: later apply same algorithm to the assign_working_day
      all_punch_times_objects = working_day.punch_times.or(working_day.uncertain_punch_times).order(:punched_datetime)
      all_punch_times_string = all_punch_times_objects.map do |apto|
        { id: apto.id, value: apto.punched_datetime.strftime('%R') }
      end
      all_punch_times = all_punch_times_objects.pluck(:punched_datetime)
      all_punch_times_count = all_punch_times.count
      all_punch_times_in_mins = all_punch_times.map do |pt|
        convert_to_total_mins(pt, @start_date)
      end
      if all_punch_times_count.positive?
        working_template = working_day.working_template
        valid_work_sections = working_template.valid_work_sections.order(:from_time_in_minute)
        valid_work_sections_ranges = valid_work_sections.map do |vws|
          vws.from_time_in_minute..vws.to_time_in_minute
        end
        first_from = valid_work_sections.first.from_time_in_minute
        valid_work_sections_count = valid_work_sections.count
        valid_work_sections_boundary_count = valid_work_sections_count * 2
        late_flag = false
        late_minutes = 0
        odd_number_punch_time = false
        if all_punch_times_count == valid_work_sections_boundary_count
          # check for all late
          valid_work_sections_count.times do |n|
            loop_from = valid_work_sections[n].from_time_in_minute
            loop_punch_time_mins = all_punch_times_in_mins[2 * n]
            if loop_from < loop_punch_time_mins
              late_flag = true
              late_minutes += (loop_punch_time_mins - loop_from)
            end
          end
        else
          # check for only first late
          first_punch_time_mins = all_punch_times_in_mins[0]
          if first_from < first_punch_time_mins
            late_flag = true
            late_minutes += (first_punch_time_mins - first_from)
          end
        end
        if all_punch_times_in_mins.size.odd?
          odd_number_punch_time = true
        else
          working_minutes = 0
          overtime_in_mins = 0
          overtime_config = working_template.overtime_config
          half_punch_times_count = all_punch_times_in_mins.size / 2
          half_punch_times_count.times do |count|
            current_punch_time_range = all_punch_times_in_mins[2 * count]..all_punch_times_in_mins[2 * count + 1]
            valid_work_sections_ranges.each do |vwsc|
              overlapping = intersection(vwsc, current_punch_time_range).presence
              working_minutes += overlapping.size unless overlapping.nil?
            end
            next unless overtime_config&.direct_after_off_work? || overtime_config&.both?

            last_to = valid_work_sections.last.to_time_in_minute
            next unless all_punch_times_in_mins[2 * count + 1] > last_to

            last_to_max_range = last_to..2159
            overlapping_after_last_to = intersection(last_to_max_range, current_punch_time_range).presence
            overtime_in_mins += overlapping_after_last_to.size unless overlapping_after_last_to.nil?
          end
          if overtime_config&.more_than_minimum?
            need_to_work_in_minutes = working_template.override_working_minutes.presence
            overtime_in_mins = working_minutes - need_to_work_in_minutes
            overtime_in_mins_ignore_lateness = overtime_in_mins
            if overtime_in_mins.positive?
              working_minutes = need_to_work_in_minutes
            else
              overtime_in_mins = 0
            end
          elsif overtime_config&.both?
            need_to_work_in_minutes = working_template.override_working_minutes.presence
            overtime_in_mins_ignore_lateness = overtime_in_mins
            overtime_in_mins -= late_minutes
            if working_minutes > need_to_work_in_minutes
              working_minutes = need_to_work_in_minutes
            elsif overtime_in_mins_ignore_lateness.positive?
              working_minutes += overtime_in_mins_ignore_lateness
              working_minutes = need_to_work_in_minutes if working_minutes > need_to_work_in_minutes
            end

            working_minutes = need_to_work_in_minutes if working_minutes > need_to_work_in_minutes
          elsif overtime_config&.disabled?
            overtime_in_mins = 0
            overtime_in_mins_ignore_lateness = 0
          elsif overtime_config&.direct_after_off_work?
            overtime_in_mins_ignore_lateness = overtime_in_mins
          end
        end
      else # no attendance
        no_attendance = true
      end
    else # no specified day's working day
      no_attendance = true
    end
    return { no_attendance: true } if no_attendance == true

    {
      no_attendance: no_attendance,
      all_punch_times_string: all_punch_times_string,
      working_minutes: working_minutes,
      overtime_in_mins: overtime_in_mins,
      overtime_in_mins_ignore_lateness: overtime_in_mins_ignore_lateness,
      odd_number_punch_time: odd_number_punch_time,
      late_flag: late_flag,
      late_minutes: late_minutes,
      working_day_id: working_day.presence&.id
    }
  end
end
