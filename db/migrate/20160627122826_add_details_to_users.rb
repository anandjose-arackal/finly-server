class AddDetailsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :name, :string
    add_column :users, :mobile_number, :string
    add_column :users, :active, :boolean, null: false, default: true
  end
end
