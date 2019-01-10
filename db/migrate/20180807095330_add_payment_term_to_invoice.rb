class AddPaymentTermToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_reference :invoices, :payment_term, index: true, foreign_key: true
  end
end
