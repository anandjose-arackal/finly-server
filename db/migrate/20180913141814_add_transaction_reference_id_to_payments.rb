class AddTransactionReferenceIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :transaction_reference_id, :string
  end
end
