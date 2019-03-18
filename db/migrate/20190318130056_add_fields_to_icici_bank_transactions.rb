class AddFieldsToIciciBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :corp_id, :string
    add_column :icici_bank_transactions, :user_id, :string
    add_column :icici_bank_transactions, :debit_acc, :string
    add_column :icici_bank_transactions, :credit_acc, :string
    add_column :icici_bank_transactions, :txn_type, :string
    add_column :icici_bank_transactions, :amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :icici_bank_transactions, :ifsc, :string
    add_column :icici_bank_transactions, :receiving_account_id, :integer, references: "BankAccount", foreign_key: true, index: true
    add_column :icici_bank_transactions, :otp, :string
    add_column :icici_bank_transactions, :payee_name, :text
    add_column :icici_bank_transactions, :remarks, :text
    add_column :icici_bank_transactions, :customer_induced, :boolean
  end
end