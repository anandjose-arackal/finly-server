class AddPaymentAgreementIdToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :payment_agreement_id, :integer
  end
end
