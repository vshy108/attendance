require 'test_helper'

class RepeatTemplateHandlerLibTest < ActiveSupport::TestCase
  include RepeatTemplateHandler

  setup do
    @worker_0 = workers(:worker_0)
    @working_template_0 = working_templates(:working_template_0)
    @working_template_1 = working_templates(:working_template_1)
  end

  test "should give correct working template if the date is under repeat range" do
    working_template = obtain_working_template_of_repeat_template(@worker_0, ('2019-01-16'.to_date + 7.days).strftime('%F'))
    assert_equal @working_template_0, working_template
  end

  test "should give nil if the date is not under repeat range" do
    working_template = obtain_working_template_of_repeat_template(@worker_0, ('2019-01-16'.to_date - 7.days).strftime('%F'))
    assert_nil working_template
  end

  test "should give latest repeate template parts' working template if more than one matches" do
    working_template = obtain_working_template_of_repeat_template(@worker_0, '2019-02-06'.to_date.strftime('%F'))
    assert_equal @working_template_1, working_template
  end
end
