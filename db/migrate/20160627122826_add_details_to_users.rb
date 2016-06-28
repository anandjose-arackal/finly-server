class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :mobile_number, :integer
    add_column :users, :active, :boolean, null: false, default: true
  end
end
