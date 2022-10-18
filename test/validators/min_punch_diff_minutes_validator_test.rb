require 'test_helper'

class MinPunchDiffMinutesValidatorTest < ActiveSupport::TestCase
  setup do
    @correct_basic_hash =
      {
        min_punch_diff_minutes: '1'
      }
  end

  test "should be success if use basic hash" do
    validation_result = MinPunchDiffMinutesValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be failed if it is integer coercible" do
    @correct_basic_hash[:min_punch_diff_minutes] = 'e'
    validation_result = MinPunchDiffMinutesValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if it is empty" do
    @correct_basic_hash[:min_punch_diff_minutes] = ''
    validation_result = MinPunchDiffMinutesValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if it is zero" do
    @correct_basic_hash[:min_punch_diff_minutes] = '0'
    validation_result = MinPunchDiffMinutesValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if it is negative" do
    @correct_basic_hash[:min_punch_diff_minutes] = '-1'
    validation_result = MinPunchDiffMinutesValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if it is decimal" do
    @correct_basic_hash[:min_punch_diff_minutes] = '1.3'
    validation_result = MinPunchDiffMinutesValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end
end
