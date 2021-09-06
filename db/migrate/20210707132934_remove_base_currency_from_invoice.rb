class RemoveBaseCurrencyFromInvoice < ActiveRecord::Migration[6.0]
  def change
    remove_column :invoices, :base_currency
    remove_column :invoices, :reporting_currency
  end
end
