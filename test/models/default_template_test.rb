require 'test_helper'

class DefaultTemplateTest < ActiveSupport::TestCase
  setup do
    @default_template_0 = default_templates(:default_template_0)
    @working_template_9 = working_templates(:working_template_9)
    @worker_9 = workers(:worker_9)
  end

  test "should create default template for same working_template" do
    default_template = DefaultTemplate.new(working_template: @default_template_0.working_template, worker: @worker_9)
    assert_equal true, default_template.save
  end
end
