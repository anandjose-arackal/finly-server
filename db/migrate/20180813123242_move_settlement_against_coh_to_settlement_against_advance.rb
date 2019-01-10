class MoveSettlementAgainstCohToSettlementAgainstAdvance < ActiveRecord::Migration[4.2]
  def change
    PaymentPurpose.seed_data

    payments = Payment.where(payment_purpose_id: PaymentPurpose.id_for(:settlement_against_cash_on_hand))
    payments.update_all(payment_purpose_id: PaymentPurpose.id_for(:settlement_against_advance))
  end
end
