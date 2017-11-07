class ChangeTdsColumnInInvoices < ActiveRecord::Migration
  def change
    rename_column :invoices, :TDS, :tds
  end
end
