class AddIsDeletedToAmounts < ActiveRecord::Migration
  def change
    add_column :amounts, :is_deleted, :boolean, default: false
  end
end
