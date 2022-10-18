class CreateWorkingDays < ActiveRecord::Migration[5.2]
  def change
    create_table :working_days do |t|
      t.date :working_date
      t.references :working_template, foreign_key: true
      t.references :worker, foreign_key: true

      t.timestamps
    end
  end
end
