class AddCurrencyIdToPaymentOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_orders, :currency_id, :integer, references: 'Currency', index: true, foreign_key: true
    PaymentOrder.all.update_all(currency_id: Currency.id_for(:INR))
    change_column_null :payment_orders, :currency_id, false
  end
end
