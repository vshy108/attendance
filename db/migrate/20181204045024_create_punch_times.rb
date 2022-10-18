class CreatePunchTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :punch_times do |t|
      t.datetime :punched_datetime
      t.references :worker, foreign_key: true

      t.timestamps
    end
  end
end
