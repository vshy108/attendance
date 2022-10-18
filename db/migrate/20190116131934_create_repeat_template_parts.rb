class CreateRepeatTemplateParts < ActiveRecord::Migration[5.2]
  def change
    create_table :repeat_template_parts do |t|
      t.date :first_repeat_date
      t.references :repeat_template, foreign_key: true
      t.references :working_template, foreign_key: true

      t.timestamps
    end
  end
end
