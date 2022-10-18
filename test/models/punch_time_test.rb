require 'test_helper'

class PunchTimeTest < ActiveSupport::TestCase
  setup do
    @worker_0 = workers(:worker_0)
  end

  test "should truncate seconds" do
    punch_time = PunchTime.new(punched_datetime: Time.zone.now, worker: @worker_0)
    assert punch_time.save
    punch_time.reload
    assert_equal 0, punch_time.punched_datetime.sec
    assert_equal 0, punch_time.punched_datetime.usec
  end
end
