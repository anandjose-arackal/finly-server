class AddNoteToRateContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contracts, :note, :string
  end
end
