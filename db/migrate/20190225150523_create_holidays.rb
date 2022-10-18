class CreateHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :holidays do |t|
      t.date :valid_date
      t.string :name
      t.string :description

      t.timestamps
    end
    add_index :holidays, :valid_date, unique: true
  end
end
