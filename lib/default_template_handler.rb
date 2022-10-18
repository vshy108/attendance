module DefaultTemplateHandler
  def obtain_default_template_last_to(default_template)
    default_template.working_template.valid_work_sections.pluck(:to_time_in_minute).max
  end

  def obtain_default_template_first_from(default_template)
    default_template.working_template.valid_work_sections.pluck(:from_time_in_minute).min
  end
end
