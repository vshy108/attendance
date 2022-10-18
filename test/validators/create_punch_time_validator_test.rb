require 'test_helper'

class CreatePunchTimeValidatorTest < ActiveSupport::TestCase
  include TimeHandler

  setup do
    @worker_0 = workers(:worker_0)
    @working_day_0 = working_days(:working_day_0)
  end

  test "should not have punched datetime later than now" do
    # cannot use 1.second because the small resolution unit is 1 minute
    validation_result = CreatePunchTimeValidator::Schema.call(punched_datetime: (current_datetime + 1.minute).to_s, worker_id: @worker_0.id.to_s)
    assert_equal false, validation_result.success?
    assert_equal 1, validation_result.messages[:punched_datetime]&.length
    assert validation_result.messages[:punched_datetime].include? 'cannot after now'
  end

  test "should successfully create if punched datetime on or before now" do
    validation_result = CreatePunchTimeValidator::Schema.call(punched_datetime: current_datetime.to_s, worker_id: @worker_0.id.to_s)
    assert_equal true, validation_result.success?
    validation_result = CreatePunchTimeValidator::Schema.call(punched_datetime: (current_datetime - 1.minute).to_s, worker_id: @worker_0.id.to_s)
    assert_equal true, validation_result.success?
  end

  test "should be success if punched datetime has valid working_day_id" do
    validation_result = CreatePunchTimeValidator::Schema.call(punched_datetime: current_datetime.to_s, worker_id: @worker_0.id.to_s, working_day_id: @working_day_0.id)
    assert_equal true, validation_result.success?
  end

  test "should be success if punched datetime has empty working_day_id" do
    validation_result = CreatePunchTimeValidator::Schema.call(punched_datetime: current_datetime.to_s, worker_id: @worker_0.id.to_s, working_day_id: "")
    assert_equal true, validation_result.success?
  end
end
