class RemoveRefundPaymentIdFromFinlyTransactions < ActiveRecord::Migration[4.2]
  def change
    remove_column :finly_transactions, :original_payment_for_refund_id, :integer
  end
end
