class AddBalanceDueWithoutCnToInvoice < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Migration.add_column :invoices, :invoice_balance_due_without_cn, :decimal, precision: 20, scale: 10, default: 0
  end
end
