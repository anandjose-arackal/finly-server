class AddChangeColumnNullToUserEmail < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, default: "", null: true
    change_column :users, :mobile_number, :string, null: false
  end
end
