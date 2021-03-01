class AddPaymentTermDaysToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :payment_term_days, :integer, default: 0
  end
end
