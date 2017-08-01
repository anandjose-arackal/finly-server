class MoveExistingPaymentsToNewFormat < ActiveRecord::Migration
  def change
    Payment.all.each do |payment|
      case payment.payment_type_id
        when PaymentType.id_for(:add_cash_on_hand)
          payment.update(payment_type_id: PaymentType.id_for(:credit))
          payment.update(payment_purpose_id: PaymentPurpose.id_for(:fund_transfer_outside_finly))
          payment.update(initiating_account: nil)
          user = User.find(payment.receiving_user_id)
          payment.update(receiving_account: user.cash_on_hand)
        when PaymentType.id_for(:deduct_cash_on_hand)
          payment.update(payment_type_id: PaymentType.id_for(:debit))
          payment.update(payment_purpose_id: PaymentPurpose.id_for(:fund_transfer_outside_finly))
          payment.update(initiating_account: nil)
          user = User.find(payment.receiving_user_id)
          payment.update(receiving_account: user.cash_on_hand)
        when PaymentType.id_for(:reimbursement_outside_finly)
          payment.update(payment_type_id: PaymentType.id_for(:credit))
          payment.update(payment_purpose_id: PaymentPurpose.id_for(:reimbursement_outside_finly))
          payment.update(initiating_account: nil)
          payment.update(receiving_account: nil)
        when PaymentType.id_for(:atm_withdrawal)
          payment.update(payment_type_id: PaymentType.id_for(:credit))
          payment.update(payment_purpose_id: PaymentPurpose.id_for(:atm_withdrawal))
          payment.update(initiating_account: nil)
          user = User.find(payment.receiving_user_id)
          payment.update(receiving_account: user.cash_on_hand)
        when PaymentType.id_for(:credit_meal_card), PaymentType.id_for(:credit_medical_card),
            PaymentType.id_for(:credit_expense_card)
          payment.update(payment_type_id: PaymentType.id_for(:credit))
          payment.update(payment_purpose_id: PaymentPurpose.id_for(:fund_transfer))
        when PaymentType.id_for(:credit_reimbursement_card)
          payment.update(payment_type_id: PaymentType.id_for(:credit))
          payment.update(payment_purpose_id: PaymentPurpose.id_for(:reimbursement))
        else
          # do nothing
      end
    end
  end
end
