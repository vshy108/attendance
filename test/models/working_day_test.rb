require 'test_helper'

class WorkingDayTest < ActiveSupport::TestCase
  setup do
    @working_day_0 = working_days(:working_day_0)
  end

  test "should not delete related punch times if remove working day" do
    first_punch_time_id = @working_day_0.punch_times.first.id
    assert_no_difference "PunchTime.count" do
      @working_day_0.destroy!
    end
    assert_nil PunchTime.find_by(id: first_punch_time_id).working_day_id
  end
end
