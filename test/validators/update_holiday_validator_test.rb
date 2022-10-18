require 'test_helper'

class UpdateHolidayValidatorTest < ActiveSupport::TestCase
  setup do
    @holiday_0 = holidays(:holiday_0)
    @correct_basic_hash =
      {
        valid_date: @holiday_0.valid_date.to_s,
        name: @holiday_0.name,
        description: @holiday_0.description
      }
  end

  test "should success" do
    validation_result = UpdateHolidayValidator::Schema.with(record: @holiday_0).call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be failed if valid date is not unique" do
    @correct_basic_hash[:valid_date] = '2019-02-05'
    validation_result = UpdateHolidayValidator::Schema.with(record: @holiday_0).call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end
end
