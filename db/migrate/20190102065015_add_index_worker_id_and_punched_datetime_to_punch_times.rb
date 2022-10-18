class AddIndexWorkerIdAndPunchedDatetimeToPunchTimes < ActiveRecord::Migration[5.2]
  def change
    add_index :punch_times, %i[worker_id punched_datetime], unique: true
  end
end
