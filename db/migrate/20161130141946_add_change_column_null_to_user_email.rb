class AddChangeColumnNullToUserEmail < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :email, :string, default: "", null: true
    change_column :users, :mobile_number, :string, null: true
  end
end
