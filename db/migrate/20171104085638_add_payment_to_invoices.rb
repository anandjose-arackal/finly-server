class AddPaymentToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :payment_id, :integer, references: "Payment", foreign_key: true, index: true
  end
end
