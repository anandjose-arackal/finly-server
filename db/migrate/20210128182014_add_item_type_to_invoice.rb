class AddItemTypeToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :tax_type, :string, default: ""
  end
end
