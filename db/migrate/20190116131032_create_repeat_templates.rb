class CreateRepeatTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :repeat_templates do |t|
      t.integer :repeat_day_difference
      t.references :worker, foreign_key: true

      t.timestamps
    end
  end
end
