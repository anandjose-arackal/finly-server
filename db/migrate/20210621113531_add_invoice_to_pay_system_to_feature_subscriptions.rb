class AddInvoiceToPaySystemToFeatureSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :feature_subscriptions, :invoice_to_pay_system, :boolean
  end
end
