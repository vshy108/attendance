class AddUncertainWorkingDayReferenceToPunchTimes < ActiveRecord::Migration[5.2]
  def change
    add_reference :punch_times, :uncertain_working_day

    add_foreign_key :punch_times, :working_days, column: :uncertain_working_day_id
  end
end
