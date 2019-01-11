class AddTransferTypeToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :payment_mode, :string
  end
end
