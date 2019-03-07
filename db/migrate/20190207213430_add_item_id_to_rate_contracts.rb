class AddItemIdToRateContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contracts, :item_id, :integer
  end
end
