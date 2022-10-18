class CreateWorkingTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :working_templates do |t|
      t.string :name
      t.integer :override_working_minutes

      t.timestamps
    end
    add_index :working_templates, :name, unique: true
  end
end
