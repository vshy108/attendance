module RepeatTemplatesHelper
  def current_template_id(child_index)
    return @repeat_template.repeat_template_parts[child_index.to_i]&.working_template_id if child_index != 'new_repeat_template_parts'

    nil
  end
end
