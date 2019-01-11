class AddModifiedByIdToReceipts < ActiveRecord::Migration[4.2]
  def change
    add_column :receipts, :modified_by_id, :integer
  end
end
