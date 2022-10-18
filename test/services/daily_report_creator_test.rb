require 'test_helper'

class DailyReportCreatorTest < ActiveSupport::TestCase
  setup do
    @special_worker_0 = workers(:special_worker_0)
    @special_worker_1 = workers(:special_worker_1)
    @special_worker_2 = workers(:special_worker_2)
    @special_worker_3 = workers(:special_worker_3)
    @special_working_day_0 = working_days(:special_working_day_0)
    @special_working_day_1 = working_days(:special_working_day_1)
    @special_working_day_2 = working_days(:special_working_day_2)
    @special_working_day_3 = working_days(:special_working_day_3)
    @special_working_day_4 = working_days(:special_working_day_4)
  end

  test "should have negative overtime_in_mins if overtime_in_mins_ignore_lateness less than late_minutes in type both" do
    worker_report = DailyReportCreator.call(@special_worker_0, '2018-12-14')
    assert_nil worker_report[:no_attendance]
    assert_equal '08:32', worker_report[:all_punch_times_string][0][:value]
    assert_equal '13:01', worker_report[:all_punch_times_string][1][:value]
    assert_equal '14:02', worker_report[:all_punch_times_string][2][:value]
    assert_equal '18:03', worker_report[:all_punch_times_string][3][:value]
    assert_equal 509, worker_report[:working_minutes]
    assert_equal false, worker_report[:odd_number_punch_time]
    assert_equal true, worker_report[:late_flag]
    assert_equal 4, worker_report[:late_minutes]
    assert_equal @special_working_day_0.id, worker_report[:working_day_id]
    assert_equal -1, worker_report[:overtime_in_mins]
    assert_equal 3, worker_report[:overtime_in_mins_ignore_lateness]
  end

  # test "should have overtime_in_mins if working_minutes is more than override working minutes" do
  #   worker_report = DailyReportCreator.call(@special_worker_0, '2018-12-15')
  #   assert_nil worker_report[:no_attendance]
  #   assert_equal '08:42', worker_report[:all_punch_times_string][0][:value]
  #   assert_equal '13:42', worker_report[:all_punch_times_string][1][:value]
  #   assert_equal '14:42', worker_report[:all_punch_times_string][2][:value]
  #   assert_equal '19:42', worker_report[:all_punch_times_string][3][:value]
  #   assert_equal 510, worker_report[:working_minutes]
  #   assert_equal false, worker_report[:odd_number_punch_time]
  #   assert_equal true, worker_report[:late_flag]
  #   assert_equal 12 + 42, worker_report[:late_minutes]
  #   assert_equal @special_working_day_1.id, worker_report[:working_day_id]
  #   assert_equal 60 + 42 - (12 + 42), worker_report[:overtime_in_mins]
  #   assert_equal 60 + 42, worker_report[:overtime_in_mins_ignore_lateness]
  # end

  # test "should have overtime_in_mins if overtime_type is direct_after_off_work" do
  #   worker_report = DailyReportCreator.call(@special_worker_1, '2018-12-16')
  #   assert_nil worker_report[:no_attendance]
  #   assert_equal '08:42', worker_report[:all_punch_times_string][0][:value]
  #   assert_equal '13:42', worker_report[:all_punch_times_string][1][:value]
  #   assert_equal '14:42', worker_report[:all_punch_times_string][2][:value]
  #   assert_equal '19:42', worker_report[:all_punch_times_string][3][:value]
  #   assert_equal 456, worker_report[:working_minutes]
  #   assert_equal false, worker_report[:odd_number_punch_time]
  #   assert_equal true, worker_report[:late_flag]
  #   assert_equal 12 + 42, worker_report[:late_minutes]
  #   assert_equal @special_working_day_2.id, worker_report[:working_day_id]
  #   assert_equal 60 + 42, worker_report[:overtime_in_mins]
  #   assert_equal 60 + 42, worker_report[:overtime_in_mins_ignore_lateness]
  # end

  # test "should have overtime_in_mins if overtime_type is more_than_minimum" do
  #   worker_report = DailyReportCreator.call(@special_worker_2, '2018-12-17')
  #   assert_nil worker_report[:no_attendance]
  #   assert_equal '08:42', worker_report[:all_punch_times_string][0][:value]
  #   assert_equal '13:42', worker_report[:all_punch_times_string][1][:value]
  #   assert_equal '14:42', worker_report[:all_punch_times_string][2][:value]
  #   assert_equal '19:42', worker_report[:all_punch_times_string][3][:value]
  #   assert_equal 510, worker_report[:working_minutes]
  #   assert_equal false, worker_report[:odd_number_punch_time]
  #   assert_equal true, worker_report[:late_flag]
  #   assert_equal 54, worker_report[:late_minutes]
  #   assert_equal @special_working_day_3.id, worker_report[:working_day_id]
  #   assert_equal 48, worker_report[:overtime_in_mins]
  #   assert_equal 48, worker_report[:overtime_in_mins_ignore_lateness]
  # end

  # test "should have zero overtime_in_mins if overtime_type is disabled" do
  #   worker_report = DailyReportCreator.call(@special_worker_3, '2018-12-18')
  #   assert_nil worker_report[:no_attendance]
  #   assert_equal '08:42', worker_report[:all_punch_times_string][0][:value]
  #   assert_equal '13:42', worker_report[:all_punch_times_string][1][:value]
  #   assert_equal '14:42', worker_report[:all_punch_times_string][2][:value]
  #   assert_equal '19:42', worker_report[:all_punch_times_string][3][:value]
  #   assert_equal 456, worker_report[:working_minutes]
  #   assert_equal false, worker_report[:odd_number_punch_time]
  #   assert_equal true, worker_report[:late_flag]
  #   assert_equal 54, worker_report[:late_minutes]
  #   assert_equal @special_working_day_4.id, worker_report[:working_day_id]
  #   assert_equal 0, worker_report[:overtime_in_mins]
  #   assert_equal 0, worker_report[:overtime_in_mins_ignore_lateness]
  # end
end
