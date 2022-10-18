class AddOvertimeValueToWorkers < ActiveRecord::Migration[5.2]
  def change
    add_column :workers, :overtime_value, :decimal, precision: 5, scale: 2
  end
end
