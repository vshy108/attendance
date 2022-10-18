require 'test_helper'

class CreateYearLeaveLimitValidatorTest < ActiveSupport::TestCase
  include TimeHandler

  setup do
    @worker_0 = workers(:worker_0)
    @correct_basic_hash =
      {
        year_number: '2020',
        allowed_annual_days_total: '50',
        worker_id: @worker_0.id.to_s
      }
  end

  test "should success" do
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should fail if year number is 2010 or less" do
    @correct_basic_hash[:year_number] = '2010'
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should fail if allowed_annual_days_total is negative" do
    @correct_basic_hash[:allowed_annual_days_total] = '-1'
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should success if allowed_annual_days_total is zero" do
    @correct_basic_hash[:allowed_annual_days_total] = '0'
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should fail if year_number and worker_id are not unique in combination" do
    @correct_basic_hash[:year_number] = '2018'
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/is not allowed/, validation_result.messages[:repeated_worker_year].first)
  end

  test "should fail if year_number is empty string" do
    @correct_basic_hash[:year_number] = ''
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should fail if allowed_annual_days_total is empty string" do
    @correct_basic_hash[:allowed_annual_days_total] = ''
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should fail if worker_id is empty string" do
    @correct_basic_hash[:worker_id] = ''
    validation_result = CreateYearLeaveLimitValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end
end
