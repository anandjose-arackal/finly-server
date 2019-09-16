class AddAgreementBasedNextDueDateToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :add_agreement_based_next_due_date, :date
  end
end
