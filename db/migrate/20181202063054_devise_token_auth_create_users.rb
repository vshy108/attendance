class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.string :provider, null: false, default: 'email'
      t.string :uid, null: false, default: ''
      t.text :tokens
    end

    User.reset_column_information
    User.find_each do |u|
      u.uid = u.email
      u.provider = 'email'
      u.save!
    end

    add_index(:users, [:uid, :provider], :unique => true)
  end

  def down
    # remove columns will remove related index also
    remove_columns :users, :provider, :uid, :tokens
  end
end
