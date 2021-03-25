class AddIsDomesticToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :is_domestic, :boolean, default: true
  end
end
