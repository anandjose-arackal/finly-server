class AddAdvanceFieldsInInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :reporting_advance_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :invoices, :reporting_po_prev_adjusted_advance, :decimal, precision: 20, scale: 10, default: 0
    add_column :invoices, :reporting_adjusted_po_advance_payable_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :purchase_orders, :advance_scheduled_date, :datetime
  end
end
