class AddOrderNumberToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :order_number, :string
    add_index :purchase_requests, :order_number
  end
end
