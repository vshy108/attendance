class CreateValidWorkSections < ActiveRecord::Migration[5.2]
  def change
    create_table :valid_work_sections do |t|
      t.integer :from_time_in_minute
      t.integer :to_time_in_minute
      t.references :working_template, foreign_key: true

      t.timestamps
    end
  end
end
