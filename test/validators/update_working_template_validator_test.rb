require 'test_helper'

class UpdateWorkingTemplateValidatorTest < ActiveSupport::TestCase
  setup do
    @working_template_0 = working_templates(:working_template_0)
    @correct_basic_hash =
      {
        name: Faker::Name.unique.name,
        override_working_minutes: '100',
        valid_work_sections_attributes: [
          { _destroy: 'false', from_time_in_minute: '10', to_time_in_minute: '200', id: '1' }
        ]
      }
  end

  test "should be success for valid_work_sections_attribute with id" do
    validation_result = UpdateWorkingTemplateValidator::Schema.with(record: WorkingTemplate.new).call(@correct_basic_hash)
    assert_equal true, validation_result.success?
    assert_equal false, validation_result.output[:valid_work_sections_attributes].first[:id].nil?
  end
end
