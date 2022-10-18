class WorkingDayPunchTimesNoEndCleaner < ApplicationService
  attr_reader :worker
  attr_reader :input_date

  def initialize(worker, input_date)
    @worker = worker
    @input_date = input_date
  end

  # clean the punch time's working_day_id and uncertain_working_day_id after 12pm for one day before input date
  # clean all punch time's working_day_id and uncertain_working_day_id and working days of the worker after that
  def call
    input_date = @input_date.to_date
    first_day = input_date - 1.day

    if @worker.present?
      pt = PunchTime.arel_table
      wd = WorkingDay.arel_table
      first_working_day = worker.working_days.find_by(working_date: first_day)
      if first_working_day.present?
        first_working_day.uncertain_punch_times.where(pt[:punched_datetime].gt(first_day.noon)).each do |upt|
          upt.update(working_day_id: nil, uncertain_working_day_id: nil)
        end
      end

      related_working_days = worker.working_days.where(wd[:working_date].gteq(first_day))
      related_working_days.each do |rwd|
        rwd.punch_times.or(rwd.uncertain_punch_times).each do |upt|
          upt.update(working_day_id: nil, uncertain_working_day_id: nil)
        end
      end
    end
  rescue ArgumentError
    nil
  end
end
