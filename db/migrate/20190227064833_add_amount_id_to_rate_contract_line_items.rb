class AddAmountIdToRateContractLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contract_line_items, :amount_id, :integer
  end
end
