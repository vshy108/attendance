module TimeHandler
  def current_datetime
    Time.zone.now
  end

  def today
    Time.zone.today
  end

  def tomorrow
    Time.zone.tomorrow
  end

  def day_diff_to_hash(day_diff)
    case day_diff
    when 0
      class_name = 'day-today'
      day_string = 'TODAY'
    when 1..7
      class_name = 'day-ago'
      day_string = "#{day_diff}D AGO"
    else
      class_name = 'day-week'
      day_string = '>1 WEEK'
    end
    { class_name: class_name, day_string: day_string }
  end

  def minutes_to_hours_minutes_string(total_minutes)
    if total_minutes.nil?
      '-'
    else
      hours = total_minutes / 60
      minutes = total_minutes % 60
      "#{hours} hrs #{minutes} mins"
    end
  end
end
