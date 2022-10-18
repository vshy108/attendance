class AppSchema < Dry::Validation::Schema
  configure do |config|
    config.messages_file = Rails.root.join('config', 'locales', 'errors.en.yml')
    config.messages = :i18n
  end

  module Types
    include Dry::Types.module

    StripChompString = Types::String.constructor do |str|
      str ? str.strip.chomp : str
    end

    FloorDecimalCurrency = Types::Coercible::Decimal.constructor do |dec|
      return dec unless dec

      multiplier = 10**2
      result = (dec * multiplier).floor.to_f / multiplier.to_f
      result.to_d
    end
  end

  # def email?(value)
  #   true
  # end

  # define! do
  #   # define common rules, if any
  # end
end
