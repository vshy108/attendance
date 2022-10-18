require 'test_helper'

class WorkerValidatorTest < ActiveSupport::TestCase
  setup do
    @working_template_0 = working_templates(:working_template_0)
    @correct_basic_hash =
      {
        name: Faker::Name.name,
        working_template_id: @working_template_0.id.to_s,
        overtime_value: '10'
      }
  end

  test "should success" do
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should failed if name is nil" do
    @correct_basic_hash[:name] = nil
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/must be filled/, validation_result.messages[:name]&.first)
  end

  test "should failed if working_template_id is invalid" do
    @correct_basic_hash[:working_template_id] = (WorkingTemplate.pluck(:id).max + 1).to_s
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/does not exist/, validation_result.messages[:working_template_id]&.first)
  end

  test "should success if overtime_value is empty" do
    @correct_basic_hash[:overtime_value] = ''
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should success if overtime_value has 3 decimal places and truncate to 2 decimal places" do
    @correct_basic_hash[:overtime_value] = '123.125'
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert validation_result.success?
    assert_equal 123.12, validation_result.output[:overtime_value]
  end

  test "should failed if overtime_value has negative value" do
    @correct_basic_hash[:overtime_value] = '-123'
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should failed if overtime_value has value larger than 999.99" do
    @correct_basic_hash[:overtime_value] = '1000'
    validation_result = WorkerValidator::Schema.call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end
end
