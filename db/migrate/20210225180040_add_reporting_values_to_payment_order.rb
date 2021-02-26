class AddReportingValuesToPaymentOrder < ActiveRecord::Migration[6.0]
  def change    
    add_column :payment_orders, :reporting_amount_processed, :decimal, default: 0
    add_column :payment_orders, :reporting_amount_requested, :decimal, default: 0
  end
end
