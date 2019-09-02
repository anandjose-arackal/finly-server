class RenameAgreementRelatedColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :security_deposits, :agreement_based_next_due_date, :payment_agreement_upcoming_date
    rename_column :beneficiary_payments, :agreement_based_next_due_date, :payment_agreement_upcoming_date
    rename_column :invoices, :payment_agreement_upcoming_invoice_date, :payment_agreement_upcoming_date
  end
end
