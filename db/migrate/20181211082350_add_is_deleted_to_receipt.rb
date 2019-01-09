class AddIsDeletedToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :is_deleted, :boolean, default: false
  end
end
