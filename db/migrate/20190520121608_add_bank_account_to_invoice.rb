class AddBankAccountToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :bank_account_id, :integer, references: "BankAccount", foreign_key: true, index: true
  end
end
