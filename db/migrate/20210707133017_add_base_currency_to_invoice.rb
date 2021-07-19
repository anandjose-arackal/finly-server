class AddBaseCurrencyToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :base_currency_id, :integer
    add_column :invoices, :reporting_currency_id, :integer
  end
end
