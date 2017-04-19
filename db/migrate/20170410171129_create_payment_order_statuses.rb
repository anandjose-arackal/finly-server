class CreatePaymentOrderStatuses < ActiveRecord::Migration
  def change
    create_table :payment_order_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    PaymentOrderStatus.seed_data
  end
end
