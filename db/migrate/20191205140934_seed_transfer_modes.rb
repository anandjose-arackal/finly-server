class SeedTransferModes < ActiveRecord::Migration[5.2]
  def change
  	TransferMode.seed_data
  end
end
