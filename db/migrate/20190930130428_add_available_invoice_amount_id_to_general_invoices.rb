class AddAvailableInvoiceAmountIdToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :available_invoice_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
