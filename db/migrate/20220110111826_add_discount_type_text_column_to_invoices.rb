class AddDiscountTypeTextColumnToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :discount_type_text, :string
  end
end
