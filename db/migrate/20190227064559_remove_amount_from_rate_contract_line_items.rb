class RemoveAmountFromRateContractLineItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :rate_contract_line_items, :amount, :decimal
  end
end
