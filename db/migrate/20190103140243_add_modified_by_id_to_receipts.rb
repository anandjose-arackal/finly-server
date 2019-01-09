class AddModifiedByIdToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :modified_by_id, :integer
  end
end
