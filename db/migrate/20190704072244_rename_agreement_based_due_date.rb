class RenameAgreementBasedDueDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :invoices, :agreement_based_next_due_date, :payment_agreement_upcoming_invoice_date
  end
end
