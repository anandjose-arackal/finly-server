class AddDeviceSecurity < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_changed_at, :datetime, index: true
    add_column :users, :last_activity_at, :datetime, index: true
    add_column :users, :expired_at, :datetime, index: true

    create_table :old_passwords do |t|
      t.string :encrypted_password, null: false
      t.string :password_archivable_type, null: false
      t.integer :password_archivable_id, null: false
      t.string :password_salt # Optional. bcrypt stores the salt in the encrypted password field so this column may not be necessary.
      t.datetime :created_at
    end
    add_index :old_passwords, [:password_archivable_type, :password_archivable_id], name: :index_password_archivable

    User.all.update_all(password_changed_at: DateTime.now, last_activity_at: DateTime.now)
  end
end
