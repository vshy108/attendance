require 'dry-validation'

class CreateHolidayValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true

      def string_to_date?(value)
        value.to_date
      rescue ArgumentError
        false
      end

      def unique?(value)
        Holiday.where(valid_date: value).none?
      end
    end

    required(:valid_date, Dry::Types['string']).filled(:str?, :string_to_date?, :unique?)
    required(:name, Dry::Types['strict.string']).filled(:str?)
    optional(:description, Dry::Types['coercible.string']) { empty? | str? }
  end
end
