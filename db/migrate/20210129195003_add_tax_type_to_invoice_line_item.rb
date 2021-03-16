class AddTaxTypeToInvoiceLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :invoice_line_items, :tax_type, :string, default: ""
  end
end
