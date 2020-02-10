class AddIncludeTaxAndTdsToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :include_tax_and_tds, :boolean, default: false
  end
end
