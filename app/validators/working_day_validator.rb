require 'dry-validation'

class WorkingDayValidator
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
    end

    required(:working_date, Dry::Types['string']).filled(:str?, :string_to_date?)
    required(:worker_id, Dry::Types['coercible.integer']).filled(:int?, record?: Worker)
    required(:working_template_id, Dry::Types['coercible.integer']).filled(:int?, record?: WorkingTemplate)
  end
end
