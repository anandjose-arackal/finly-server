class AddRateContractItemIdToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :rate_contract_item_id, :integer
  end
end
