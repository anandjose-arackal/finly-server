class MoveFinlyTransactionsToSettlementAgainstAdvance < ActiveRecord::Migration[4.2]
  def change
    PaymentPurpose.seed_data
    finly_transactions = FinlyTransaction.where(payment_purpose_id: PaymentPurpose.id_for(:settlement_against_cash_on_hand))
    finly_transactions.update_all(payment_purpose_id: PaymentPurpose.id_for(:settlement_against_advance))
  end
end
