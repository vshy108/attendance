require 'test_helper'

class ValidWorkSectionTest < ActiveSupport::TestCase
  test "should not save if missing working_template" do
    valid_work_section = ValidWorkSection.new(
      from_time_in_minute: 0, to_time_in_minute: 1000
    )
    assert_equal false, valid_work_section.save
  end
end
