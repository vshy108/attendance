require 'test_helper'

class PresenteeAndAbsenteeGeneratorTest < ActiveSupport::TestCase
  include TimeHandler

  test "should have today number of presentee if given empty hash" do
    target_date = today.strftime('%F')
    date_string, today_string, q_worker, other_workers, pagy, workers =
      PresenteeAndAbsenteeGenerator.call({})
    pt = PunchTime.arel_table
    expected_worker_size = PunchTime.where(
      pt[:punched_datetime].gteq(target_date.to_date.beginning_of_day).and(
        pt[:punched_datetime].lteq(target_date.to_date.end_of_day)
      )
    ).pluck(:worker_id).uniq.size
    assert_equal expected_worker_size, workers.size
  end

  test "should have equal presentee number" do
    target_date = PunchTime.first.punched_datetime.strftime('%F')
    _, _, _, _, _, workers =
      PresenteeAndAbsenteeGenerator.call(
        q: {
          punch_times_punched_datetime_gteq: target_date
        }
      )
    pt = PunchTime.arel_table
    expected_worker_size = PunchTime.where(
      pt[:punched_datetime].gteq(target_date.to_date.beginning_of_day).and(
        pt[:punched_datetime].lteq(target_date.to_date.end_of_day)
      )
    ).pluck(:worker_id).uniq.size
    assert_equal expected_worker_size, workers.size
  end
end
