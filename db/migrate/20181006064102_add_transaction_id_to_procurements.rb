class AddTransactionIdToProcurements < ActiveRecord::Migration[4.2]
  def change
    add_column :procurements, :transaction_id, :string

    Purpose.seed_data
  end
end
