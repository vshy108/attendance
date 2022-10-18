module ApplicationHelper
  def render_header(current_user, context)
    if current_user
      context.render(partial: "/application/has_user_header")
    else
      context.render(partial: "/application/nil_user_header")
    end
  end

  def nav_link(link_text, link_path)
    return nil if current_user.blank?

    class_name = current_page?(link_path) ? 'current-tab' : nil
    class_name = 'current-tab' if current_page?(root_path) && link_path == homes_dashboard_path
    link_to link_text, link_path, class: class_name
  end

  def render_error_messages(errors, object_name, context)
    if errors.present?
      if errors[:override_working_minutes].presence
        errors[:minimum_working_hours] = errors.delete :override_working_minutes
        errors[:minimum_working_hours].each do |msg|
          msg.gsub!(/override_working_minutes/, 'minimum_working_hours').gsub!(/1440/, '24 hours')
        end
      end
      if errors.keys.include?(:to_time_in_minute) && errors[:to_time_in_minute].length
        new_to_time_in_minute = errors[:to_time_in_minute].map do |ttim|
          ttim.gsub(/2160/, 'tomorrow 12:00').gsub(/-720/, 'yesterday 12:00')
        end
        errors[:to_time_in_minute] = new_to_time_in_minute
      end
      if errors.keys.include?(:from_time_in_minute) && errors[:from_time_in_minute].length
        new_from_time_in_minute = errors[:from_time_in_minute].map do |ftim|
          ftim = ftim.gsub(/-720/, 'yesterday 12:00').gsub(/2160/, 'tomorrow 12:00')
        end
        errors[:from_time_in_minute] = new_from_time_in_minute
      end
      if errors.keys.include?(:longer_one_day) && errors[:longer_one_day].length
        new_longer_one_day = errors[:longer_one_day].map do |nlod|
          nlod = nlod.gsub(/less than 1440/, 'within one day')
        end
        errors[:longer_one_day] = new_longer_one_day
      end
      context.render("/application/validation_error",
                     object_name: object_name,
                     num_errors_string: pluralize(errors.count, "error"),
                     error_messages: errors.values.map(&:first))
    end
  end

  def is_shrink?
    cookies[:isShrink] == 'true' ? 'shrink' : ''
  end

  def formatted_time_range(total_minutes)
    return '-' if total_minutes.blank?

    hours = total_minutes / 60
    minutes = total_minutes % 60
    if hours.negative?
      day_string = 'Yesterday'
      hours += 24
    elsif hours >= 24
      day_string = 'Tomorrow'
      hours -= 24
    else
      day_string = 'Today'
    end
    "#{day_string} #{hours}:#{minutes.to_s.rjust(2, '0')}"
  end

  def minutes_to_hhmm(minutes)
    if minutes.blank? || minutes == '-'
      '-'
    else
      is_negative = false
      if minutes.negative?
        is_negative = true
        minutes = - minutes
      end
      hours = minutes / 60
      rest = minutes % 60
      "#{is_negative ? '-' : ''}#{hours.to_s.rjust(2, '0')}:#{rest.to_s.rjust(2, '0')}"
    end
  end

  def render_ot_pay(overtime_value, ot_minutes)
    if overtime_value.presence && ot_minutes.presence && ot_minutes != '-'
      "#{number_with_precision(overtime_value / 60.00 * ot_minutes, precision: 2)}"
    else
      '-'
    end
  end
end
