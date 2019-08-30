class AddAgreementRelatedColumnsToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :payment_agreement_escalation_id, :integer
    add_column :invoices, :invoice_frequency_id, :integer
  end
end
