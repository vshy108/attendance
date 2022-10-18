require 'test_helper'

class UpdateWorkingTemplateOvertimeValidatorTest < ActiveSupport::TestCase
  setup do
    @working_template_0 = working_templates(:working_template_0)
    @correct_basic_hash =
      {
        override_working_minutes: '600'
      }
  end

  test "should be success for valid override_working_minutes" do
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema.with(total_sections_minutes: 600, overtime_type: 'both').call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be failed for larger override_working_minutes" do
    @correct_basic_hash[:override_working_minutes] = '601'
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema.with(total_sections_minutes: 600, overtime_type: 'both').call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    validation_result.messages.key? :override_working_minutes
  end

  test "should be failed for nil override_working_minutes if overtime_type is both" do
    @correct_basic_hash[:override_working_minutes] = nil
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema.with(total_sections_minutes: 600, overtime_type: 'both').call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    validation_result.messages.key? :override_working_minutes
  end

  test "should be failed for nil override_working_minutes if overtime_type is more_than_minimum" do
    @correct_basic_hash[:override_working_minutes] = nil
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema.with(total_sections_minutes: 600, overtime_type: 'both').call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    validation_result.messages.key? :override_working_minutes
  end

  test "should be success for nil override_working_minutes if overtime_type is disabled" do
    @correct_basic_hash[:override_working_minutes] = nil
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema.with(total_sections_minutes: 600, overtime_type: 'disabled').call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be success for nil override_working_minutes if overtime_type is direct_after_off_work" do
    @correct_basic_hash[:override_working_minutes] = nil
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema.with(total_sections_minutes: 600, overtime_type: 'disabled').call(@correct_basic_hash)
    assert validation_result.success?
  end
end
