class AddWorkingDayToPunchTimes < ActiveRecord::Migration[5.2]
  def change
    add_reference :punch_times, :working_day, foreign_key: true
  end
end
