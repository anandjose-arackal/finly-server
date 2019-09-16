class AddTransferTypeToIciciBankTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :transfer_type, :string
  end
end
