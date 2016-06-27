class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :mobile_number, :integer
    add_column :users, :active, :boolean, null: false, default: true
    add_reference :users, :user_type, index: true, foreign_key: true, null: false
  end
end
