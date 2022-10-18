require 'dry-validation'

class UpdateHolidayValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true
      option :record

      def string_to_date?(value)
        value.to_date
      rescue ArgumentError
        false
      end

      def unique?(value)
        Holiday.where.not(id: record.id).where(valid_date: value).none?
      end
    end

    required(:valid_date, Dry::Types['string']).filled(:str?, :string_to_date?, :unique?)
    required(:name, Dry::Types['strict.string']).filled(:str?)
    optional(:description, Dry::Types['coercible.string']) { empty? | str? }
  end
end
