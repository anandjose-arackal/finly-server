class AddPaymentAgreementUpcomingInvoiceToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :is_payment_agreement_upcoming_invoice, :boolean
    add_column :invoices, :recurring_invoice_id, :integer
    add_index :invoices, :recurring_invoice_id
  end
end
