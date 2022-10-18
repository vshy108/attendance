require 'test_helper'

class CreateHolidayValidatorTest < ActiveSupport::TestCase
  setup do
    @holiday_0 = holidays(:holiday_0)
    @correct_basic_hash =
      {
        valid_date: '2019-12-25',
        name: 'Xmas',
        description: 'Public'
      }
  end

  test "should success" do
    validation_result = CreateHolidayValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be failed if valid_date is not unique" do
    @correct_basic_hash[:valid_date] = '2019-01-01'
    validation_result = CreateHolidayValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if name is empty" do
    @correct_basic_hash[:name] = ''
    validation_result = CreateHolidayValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if valid_date is empty" do
    @correct_basic_hash[:valid_date] = ''
    validation_result = CreateHolidayValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should success if description is empty" do
    @correct_basic_hash[:description] = ''
    validation_result = CreateHolidayValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should success if valid_date is after today" do
    @correct_basic_hash[:valid_date] =( Time.zone.today + 1.day).to_s
    validation_result = CreateHolidayValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end
end
