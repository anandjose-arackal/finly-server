class AddAddressDetailsToUsers < ActiveRecord::Migration
  create_table :states do |t|
    t.string :name, null:false
    t.string :code, null: false

    t.timestamps null: false
  end
  def change
    remove_column :users, :name
    add_column :users, :first_name, :string, null: false
    add_column :users, :maiden_name, :string
    add_column :users, :last_name, :string, null: false
    add_column :user_profiles, :date_of_birth, :date, null: false
    add_column :user_profiles, :gender, :string, null: false
    add_column :user_profiles, :address_1, :string, null: false
    add_column :user_profiles, :address_2, :string, null: false
    add_column :user_profiles, :city, :string, null: false
    add_reference :user_profiles, :state, null: false
    add_column :user_profiles, :pin_code, :string, null: false
  end
end
