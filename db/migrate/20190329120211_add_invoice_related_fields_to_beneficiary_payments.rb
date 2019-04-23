class AddInvoiceRelatedFieldsToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :invoice_number, :text
    add_column :beneficiary_payments, :invoice_date, :date
    add_column :beneficiary_payments, :invoice_due_date, :date

    add_index :beneficiary_payments, :invoice_number, :length => { :invoice_number => 20 }
    add_index :beneficiary_payments, :invoice_date
    add_index :beneficiary_payments, :invoice_due_date
  end
end
