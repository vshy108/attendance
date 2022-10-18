class CreateOvertimeConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :overtime_configs do |t|
      t.references :working_template, foreign_key: true
      t.string :overtime_type

      t.timestamps
    end
  end
end
