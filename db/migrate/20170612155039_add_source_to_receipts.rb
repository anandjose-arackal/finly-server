class AddSourceToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :sourcable_id, :integer, index: true
    add_column :receipts, :sourcable_type, :integer, index: true
  end
end
