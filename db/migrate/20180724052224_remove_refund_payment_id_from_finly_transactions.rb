class RemoveRefundPaymentIdFromFinlyTransactions < ActiveRecord::Migration
  def change
    remove_column :finly_transactions, :original_payment_for_refund_id, :integer
  end
end
