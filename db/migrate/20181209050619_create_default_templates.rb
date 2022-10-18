class CreateDefaultTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :default_templates do |t|
      t.references :working_template, foreign_key: true
      t.references :worker, foreign_key: true

      t.timestamps
    end
  end
end
