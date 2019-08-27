class AddBankAccountProviderInBprs < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :bank_account_provider_id, :integer, references: "BankAccountProvider", foreign_key: true, index: true
    add_column :payments, :bank_account_provider_id, :integer, references: "BankAccountProvider", foreign_key: true, index: true
    add_column :payment_orders, :bank_account_provider_id, :integer, references: "BankAccountProvider", foreign_key: true, index: true
  end
end
