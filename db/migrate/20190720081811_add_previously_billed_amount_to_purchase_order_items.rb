class AddPreviouslyBilledAmountToPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_items, :previously_billed_amount, :decimal, default: 0
  end
end
