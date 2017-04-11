class CreatePaymentOrderTypes < ActiveRecord::Migration
  def change
    create_table :payment_order_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    PaymentOrderType.seed_data
  end
end
