module RepeatTemplateHandler
  def obtain_working_template_of_repeat_template(worker, target_date_string)
    begin
      target_date = target_date_string.to_date
    rescue ArgumentError
      return nil
    end

    repeat_template = worker.repeat_template
    return nil if repeat_template.nil?

    repeat_day_difference = repeat_template.repeat_day_difference

    matched_repeat_template_parts = worker.repeat_template.repeat_template_parts.select do |repeat_template_part|
      first_repeat_date = repeat_template_part.first_repeat_date
      (first_repeat_date <= target_date) && ((repeat_template_part.first_repeat_date - target_date) % repeat_day_difference).zero?
    end
    if matched_repeat_template_parts.length.positive?
      selected_repeate_template_part = matched_repeat_template_parts.max_by(&:first_repeat_date)
      return selected_repeate_template_part.working_template
    end
    nil
  end

  def obtain_earliest_for_one_repeat_template(repeat_template)
    repeat_template.repeat_template_parts.min_by(&:first_repeat_date).first_repeat_date
  end
end
