require 'test_helper'

class WorkingTemplateTest < ActiveSupport::TestCase
  setup do
    @working_template_0 = working_templates(:working_template_0)
  end

  test "should not delete working template if any working day is binding it" do
    # exception = assert_raises ActiveRecord::RecordNotDestroyed do
    #   @working_template_0.destroy!
    # end
    # assert_equal('Failed to destroy the record', exception.message)
    exception = assert_raises ActiveRecord::DeleteRestrictionError do
      @working_template_0.destroy!
    end
    assert_match(/dependent/, exception.message)
  end
end
