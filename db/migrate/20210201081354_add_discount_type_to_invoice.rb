class AddDiscountTypeToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :discount_type, :string, default: ""
  end
end
