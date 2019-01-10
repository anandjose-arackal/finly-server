class ChangeTdsColumnInInvoices < ActiveRecord::Migration[4.2]
  def change
    rename_column :invoices, :TDS, :tds
  end
end
