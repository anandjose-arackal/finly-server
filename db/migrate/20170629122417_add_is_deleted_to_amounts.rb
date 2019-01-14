class AddIsDeletedToAmounts < ActiveRecord::Migration[4.2]
  def change
    add_column :amounts, :is_deleted, :boolean, default: false
  end
end
