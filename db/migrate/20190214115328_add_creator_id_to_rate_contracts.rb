class AddCreatorIdToRateContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contracts, :creator_id, :integer
  end
end
