class RemoveImpsInTransferModes < ActiveRecord::Migration[5.2]
  def change
  	remove_column :transfer_modes, :imps, :boolean
  	remove_column :transfer_modes, :neft, :boolean
  	remove_column :transfer_modes, :rtgs, :boolean
  	remove_column :transfer_modes, :company_id, :integer

  	add_column :transfer_modes, :name, :string
  	add_index :transfer_modes, :name
  end
end
