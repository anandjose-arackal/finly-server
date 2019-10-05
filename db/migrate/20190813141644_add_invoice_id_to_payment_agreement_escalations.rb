class AddInvoiceIdToPaymentAgreementEscalations < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreement_escalations, :invoice_id, :integer
    add_index :payment_agreement_escalations, :invoice_id
  end
end
