class AddUniqueIndexToRepeatTemplatesAndParts < ActiveRecord::Migration[5.2]
  def change
    remove_index :repeat_templates, :worker_id
    add_index :repeat_templates, :worker_id, unique: true
    add_index :repeat_template_parts, %i[repeat_template_id first_repeat_date], unique: true, name: 'by_repeat_date_in_template'
  end
end
