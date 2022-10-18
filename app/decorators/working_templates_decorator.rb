class WorkingTemplatesDecorator
  delegate :name, to: :working_template
  delegate :id, to: :working_template

  def initialize(working_template)
    @working_template = working_template
  end

  def default_template_count
    @working_template.default_templates.count || '-'
  end

  def overtime_type
    @working_template.overtime_config.overtime_type.titleize
  end

  def original_object
    @working_template
  end

  def override_working_minutes
    @working_template.override_working_minutes || '-'
  end

  def is_modification_allowed?
    @working_template.default_templates.none? && @working_template.working_days.none? && @working_template.repeat_template_parts.none?
  end

  private

  attr_reader :working_template
end
