class CreateYearLeaveLimits < ActiveRecord::Migration[5.2]
  def change
    create_table :year_leave_limits do |t|
      t.integer :year_number
      t.integer :allowed_annual_days_total
      t.references :worker, foreign_key: true

      t.timestamps
    end
    add_index :year_leave_limits, %i(worker_id year_number), unique: true
  end
end
