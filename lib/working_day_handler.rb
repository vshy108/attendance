module WorkingDayHandler
  def obtain_last_to(working_day)
    working_day.working_template.valid_work_sections.pluck(:to_time_in_minute).max
  end

  def obtain_first_from(working_day)
    working_day.working_template.valid_work_sections.pluck(:from_time_in_minute).min
  end
end
