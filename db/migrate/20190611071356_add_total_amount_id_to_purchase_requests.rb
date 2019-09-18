class AddTotalAmountIdToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :total_amount_id, :integer
    add_index :purchase_requests, :total_amount_id
  end
end
