require 'test_helper'

class CreateRepeatTemplateValidatorTest < ActiveSupport::TestCase
  setup do
    @worker_2 = workers(:worker_2)
    @worker_0 = workers(:worker_0)
    @working_template_0 = working_templates(:working_template_0)
    @working_template_1 = working_templates(:working_template_1)
    @correct_basic_hash =
      {
        repeat_day_difference: '7',
        worker_id: @worker_2.id.to_s,
        repeat_template_parts_attributes: [
          { _destroy: 'false', working_template_id: @working_template_0.id.to_s, first_repeat_date: Time.zone.today.strftime('%F') },
          { _destroy: 'false', working_template_id: @working_template_1.id.to_s, first_repeat_date: Time.zone.yesterday.strftime('%F') }
        ]
      }
  end

  test "should be success if use basic hash" do
    validation_result = CreateRepeatTemplateValidator::Schema
                        .call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be failed if worker has repeat template already" do
    @correct_basic_hash[:worker_id] = @worker_0.id.to_s
    validation_result = CreateRepeatTemplateValidator::Schema
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end

  test "should be failed if duplicate first_repeat_date is found" do
    @correct_basic_hash[:repeat_template_parts_attributes][1][:first_repeat_date] = Time.zone.today.strftime('%F')
    validation_result = CreateRepeatTemplateValidator::Schema
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end
end
