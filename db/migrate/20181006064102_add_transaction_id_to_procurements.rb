class AddTransactionIdToProcurements < ActiveRecord::Migration
  def change
    add_column :procurements, :transaction_id, :string

    Purpose.seed_data
  end
end
