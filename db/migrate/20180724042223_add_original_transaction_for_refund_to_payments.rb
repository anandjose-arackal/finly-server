class AddOriginalTransactionForRefundToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :original_payment_for_refund_id, :integer, references: "Payment", index: true, foreign_key: true
  end
end