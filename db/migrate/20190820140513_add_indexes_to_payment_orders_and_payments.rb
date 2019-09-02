class AddIndexesToPaymentOrdersAndPayments < ActiveRecord::Migration[5.2]
  def change
    # add_index :payment_orders, :created_at
    add_index :payment_orders, :payment_purpose_id
  end
end
