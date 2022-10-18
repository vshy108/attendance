require 'dry-validation'

class WorkerValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true
      option :record

      def record?(klass, value)
        klass.where(id: value).lazy.any?
      end
    end

    required(:name, AppSchema::Types::StripChompString).filled(:str?)
    required(:working_template_id, Dry::Types['coercible.integer']).filled(:int?, record?: WorkingTemplate)
    optional(:overtime_value, AppSchema::Types::FloorDecimalCurrency) do
      empty? | (filled? > decimal? & (lteq?(999.99) & gteq?(0)))
    end
  end
end
