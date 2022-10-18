module WorkingTemplateHandler
  def obtain_working_template_last_to(working_template)
    working_template.valid_work_sections.pluck(:to_time_in_minute).max
  end

  def obtain_working_template_first_from(working_template)
    working_template.valid_work_sections.pluck(:from_time_in_minute).min
  end
end
