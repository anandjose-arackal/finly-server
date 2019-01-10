class AddIsDeletedToReceipt < ActiveRecord::Migration[4.2]
  def change
    add_column :receipts, :is_deleted, :boolean, default: false
  end
end
