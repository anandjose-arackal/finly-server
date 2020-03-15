class AddPaymentProcessingAmountToBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    # add_column :budget_trails, :payment_processing_amount_before_tax_value, :decimal, precision: 20, scale: 10, default: 0
    # add_column :budget_trails, :payment_processing_amount_after_tax_value, :decimal, precision: 20, scale: 10, default: 0
  end
end
