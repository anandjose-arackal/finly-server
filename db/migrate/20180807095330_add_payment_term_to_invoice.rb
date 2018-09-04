class AddPaymentTermToInvoice < ActiveRecord::Migration
  def change
    add_reference :invoices, :payment_term, index: true, foreign_key: true
  end
end
