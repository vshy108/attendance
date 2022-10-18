require 'dry-validation'

# TODO: need to clone the predicate from CreateWorkingTemplateValidator
class UpdateWorkingTemplateValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true
      option :record
      option :overtime_type

      def case_insensitive_unique?(attr_name, value)
        record.class
              .where.not(id: record.id)
              .where("LOWER(#{attr_name}) = ?", value.downcase).empty?
      end

      def need_override_working_minutes?(value)
        disabled = OvertimeConfig.overtime_types[:disabled]
        direct_after_off_work = OvertimeConfig.overtime_types[:direct_after_off_work]
        no_need_override = [disabled, direct_after_off_work].include?(overtime_type)
        return false if !no_need_override && value.presence.nil?

        true
      end
    end

    # add need specifed Dry::Types because of config.type_specs = true
    required(:name, AppSchema::Types::StripChompString).filled(case_insensitive_unique?: :name)
    # 1440 minutes is 24 hours
    required(:override_working_minutes, Dry::Types['optional.coercible.integer']) { need_override_working_minutes? & (empty? | (int? > ((lt? 1440) & (gteq? 0)))) }
    required(:valid_work_sections_attributes, Dry::Types['array'].of(Dry::Types['coercible.hash'])).each do
      schema do
        required(:_destroy, Dry::Types['strict.string']).filled(:str?)
        # -12 x 60 = -720, yesterday 12pm
        required(:from_time_in_minute, Dry::Types['coercible.integer']).filled(:int?, gt?: -720, lt?: 2160)
        # (12 + 24) x 60 = 36 x 60 = 2160, tomorrow 12pm
        required(:to_time_in_minute, Dry::Types['coercible.integer']).filled(:int?, gt?: -720, lt?: 2160)
        optional(:id, Dry::Types['coercible.integer']) { empty? | int? }
      end
    end

    validate(valid_relationship_from_to: :valid_work_sections_attributes) do |valid_work_sections_attributes|
      if valid_work_sections_attributes.is_a?(Array)
        result = valid_work_sections_attributes.lazy.any? do |section|
          section[:from_time_in_minute].to_i > section[:to_time_in_minute].to_i
        end
        !result
      else
        true
      end
    end

    validate(overlapping_valid_work_sections: :valid_work_sections_attributes) do |valid_work_sections_attributes|
      if valid_work_sections_attributes.is_a?(Array)
        ranges = []
        valid_work_sections_attributes.each do |section|
          if section[:from_time_in_minute]&.to_i && section[:to_time_in_minute]&.to_i
            ranges.push(section[:from_time_in_minute]&.to_i..section[:to_time_in_minute]&.to_i)
          end
        end
        if ranges.length >= 1
          overlapping = false
          ranges.lazy.each_with_index do |range, index|
            check_with_ranges = ranges.drop(index + 1)
            overlapping = check_with_ranges.lazy.any? { |check_with_range| check_with_range.overlaps?(range) }
            break if overlapping
          end
          !overlapping
        else
          true
        end
      else
        true
      end
    end

    validate(longer_one_day: :valid_work_sections_attributes) do |valid_work_sections_attributes|
      if valid_work_sections_attributes.is_a?(Array)
        ranges = []
        valid_work_sections_attributes.each do |section|
          if section[:from_time_in_minute]&.to_i && section[:to_time_in_minute]&.to_i
            ranges.push(section[:from_time_in_minute]&.to_i..section[:to_time_in_minute]&.to_i)
          end
        end
        max = ranges.collect(&:max).compact&.max
        min = ranges.collect(&:min).compact&.min
        if max && min
          max - min < 1440
        else
          true # let others validate handles
        end
      else
        true
      end
    end

    validate(valid_minimum_working_hours: %i[valid_work_sections_attributes override_working_minutes]) do |valid_work_sections_attributes, override_working_minutes|
      if valid_work_sections_attributes.is_a?(Array) && override_working_minutes.present?
        total_differences = 0
        valid_work_sections_attributes.each do |section|
          from_time_in_minute = section[:from_time_in_minute]&.to_i
          to_time_in_minute = section[:to_time_in_minute]&.to_i
          if from_time_in_minute && to_time_in_minute
            total_differences = total_differences + to_time_in_minute - from_time_in_minute
          end
        end
        total_differences - override_working_minutes.to_i >= 0
      else
        true
      end
    end

    validate(zero_valid_work_sections: :valid_work_sections_attributes) do |valid_work_sections_attributes|
      if valid_work_sections_attributes.present?
        valid_work_sections_attributes.reject { |valid_work_section| valid_work_section[:_destroy] == '1' }.any?
      else
        false
      end
    end
  end
end
