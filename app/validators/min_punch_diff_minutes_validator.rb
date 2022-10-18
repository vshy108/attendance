require 'dry-validation'

class MinPunchDiffMinutesValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true
    end

    required(:min_punch_diff_minutes, Dry::Types['optional.coercible.integer']).filled(:int?, gteq?: 1)
  end
end
