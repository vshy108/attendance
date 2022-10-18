require 'test_helper'

class UpdateYearLeaveLimitValidatorTest < ActiveSupport::TestCase
  include TimeHandler

  setup do
    @worker_0 = workers(:worker_0)
    @year_leave_limit_0 = year_leave_limits(:year_leave_limit_0)
    @correct_basic_hash =
      {
        year_number: '2018',
        allowed_annual_days_total: '15',
        worker_id: @worker_0.id.to_s
      }
  end

  test "should success" do
    validation_result = UpdateYearLeaveLimitValidator::Schema.with(record: @year_leave_limit_0).call(@correct_basic_hash)
    assert validation_result.success?
  end
end
