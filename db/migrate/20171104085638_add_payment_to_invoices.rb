class AddPaymentToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :payment_id, :integer, references: "Payment", foreign_key: true, index: true
  end
end
