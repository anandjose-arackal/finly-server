class AddPaymentTermToOutwardInvoice < ActiveRecord::Migration
  def change
    add_reference :outward_invoices, :payment_term, index: true, foreign_key: true
  end
end
