require 'test_helper'

class UpdateRepeatTemplateValidatorTest < ActiveSupport::TestCase
  setup do
    @worker_2 = workers(:worker_2)
    @worker_0 = workers(:worker_0)
    @working_template_0 = working_templates(:working_template_0)
    @working_template_1 = working_templates(:working_template_1)
    @repeat_template_one = repeat_templates(:repeat_template_one)
    @repeat_template_part_one = repeat_template_parts(:repeat_template_part_one)
    @correct_basic_hash =
      {
        repeat_day_difference: @repeat_template_one.repeat_day_difference,
        worker_id: @repeat_template_one.worker_id.to_s,
        repeat_template_parts_attributes: [
          { _destroy: 'false', working_template_id: @repeat_template_part_one.working_template.id.to_s, first_repeat_date: @repeat_template_part_one.first_repeat_date.to_s, id: @repeat_template_part_one.id.to_s }
        ]
      }
  end

  test "should be success if use basic hash" do
    validation_result = UpdateRepeatTemplateValidator::Schema
                        .with(record: @repeat_template_one)
                        .call(@correct_basic_hash)
    assert validation_result.success?
  end

  test "should be failed if all repeat_template_parts_attributes is _destroy with value 1" do
    @correct_basic_hash[:repeat_template_parts_attributes][0][:_destroy] = '1'
    validation_result = UpdateRepeatTemplateValidator::Schema
                        .with(record: @repeat_template_one)
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
  end
end
