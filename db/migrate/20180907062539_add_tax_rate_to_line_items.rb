class AddTaxRateToLineItems < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_order_items, :tax_rate_id, :integer, references: 'TaxRate', foreign_key: true, index: true
    add_column :invoice_line_items, :tax_rate_id, :integer, references: 'TaxRate', foreign_key: true, index: true
  end
end
