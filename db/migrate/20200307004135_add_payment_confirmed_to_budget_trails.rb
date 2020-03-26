class AddPaymentConfirmedToBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_trails, :payment_confirmed, :boolean, default: false
  end
end
