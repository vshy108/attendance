class DailyAttendanceCreator < ApplicationService
  attr_reader :worker
  attr_reader :date_related
  include TimeHandler

  def initialize(worker, date_related)
    @worker = worker
    @date_related = date_related
  end

  def call
    first_month_date = @date_related.beginning_of_month
    last_month_date = @date_related.end_of_month
    pt = PunchTime.arel_table
    (first_month_date..last_month_date).map do |date|
      # where before select is faster
      @worker.punch_times.where(pt[:punched_datetime].gteq(date.beginning_of_day).and(pt[:punched_datetime].lteq(date.end_of_day)))
             .order(pt[:punched_datetime]).select(pt[:id], pt[:punched_datetime])
    end
  end
end
