require 'dry-validation'

class UpdateRepeatTemplateValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true
      option :record

      def record?(klass, value)
        klass.where(id: value).lazy.any?
      end

      def string_to_date?(value)
        value.to_date
      rescue ArgumentError
        false
      end

      def unique?(value)
        RepeatTemplate.where.not(id: record.id).where(worker_id: value).none?
      end
    end

    required(:repeat_day_difference, Dry::Types['coercible.integer']).filled(:int?, gteq?: 1)
    required(:worker_id, Dry::Types['coercible.integer']).filled(:int?, :unique?, record?: Worker)
    required(:repeat_template_parts_attributes, Dry::Types['array'].of(Dry::Types['coercible.hash'])).each do
      schema do
        required(:_destroy, Dry::Types['strict.string']).filled(:str?)
        required(:first_repeat_date, Dry::Types['string']).filled(:str?, :string_to_date?)
        required(:working_template_id, Dry::Types['coercible.integer']).filled(:int?, record?: WorkingTemplate)
        optional(:id, Dry::Types['coercible.integer']) { empty? | int? }
      end
    end

    validate(repeated_first_repeat_date: :repeat_template_parts_attributes) do |repeat_template_parts_attribute|
      first_repeat_date_array = repeat_template_parts_attribute.pluck(:first_repeat_date)
      first_repeat_date_array.uniq.length == first_repeat_date_array.length
    end

    validate(zero_repeat_template_parts: :repeat_template_parts_attributes) do |repeat_template_parts_attributes|
      if repeat_template_parts_attributes.present?
        repeat_template_parts_attributes.reject { |repeat_template_part| repeat_template_part[:_destroy] == '1' }.any?
      else
        false
      end
    end
  end
end
