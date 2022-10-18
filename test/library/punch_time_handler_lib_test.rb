require 'test_helper'

class PunchTimeHandlerLibTest < ActiveSupport::TestCase
  include PunchTimeHandler

  setup do
    @punch_time_0 = punch_times(:punch_time_0)
    @punch_time_no_working_day = punch_times(:punch_time_no_working_day)
    @worker_0 = workers(:worker_0)
  end

  test "should have same waiting_process_count" do
    assert_equal PunchTime.where(working_day_id: nil, uncertain_working_day_id: nil).count, waiting_process_count
  end

  test "should failed silently if punch time has working_day_id" do
    output = assign_working_day(@punch_time_0.id)
    assert_nil output
  end

  test "should success if given punch time without working day" do
    output = assign_working_day(@punch_time_no_working_day.id)
    # the value is true because punch_time.save
    # the value is nil because of return
    assert_nil output
  end

  test "should return true if database has punch time within min_punch_diff_minutes before" do
    latest_punch_time = @worker_0.punch_times.order(punched_datetime: :desc).first
    Setting.min_punch_diff_minutes = 10
    result = worker_has_punch_times_within?(
      @worker_0,
      latest_punch_time.punched_datetime + Setting.min_punch_diff_minutes.minutes - 1
    )
    assert result
  end

  test "should return true if database has punch time with same punched_datetime" do
    latest_punch_time = @worker_0.punch_times.order(punched_datetime: :desc).first
    Setting.min_punch_diff_minutes = 10
    result = worker_has_punch_times_within?(
      @worker_0,
      latest_punch_time.punched_datetime
    )
    assert result
  end

  test "should return false if database has punch time at min_punch_diff_minutes before" do
    latest_punch_time = @worker_0.punch_times.order(punched_datetime: :desc).first
    Setting.min_punch_diff_minutes = 10
    result = worker_has_punch_times_within?(
      @worker_0,
      latest_punch_time.punched_datetime + Setting.min_punch_diff_minutes.minutes
    )
    assert_equal false, result
  end
end
