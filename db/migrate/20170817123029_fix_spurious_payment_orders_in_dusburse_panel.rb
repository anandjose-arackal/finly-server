class FixSpuriousPaymentOrdersInDusbursePanel < ActiveRecord::Migration
  def change
    PaymentOrder.where(payment_purpose_id: PaymentPurpose.id_for(:corporate_balance_load)).where.not(receiving_account_type: ["ItzCashCompanyAccount", "YesBankCompanyAccount"]).each do |payment_order|
      # first retrieve the card type, and hence the payment purpose
      card_program = payment_order.payments.first.receiving_account.card_program.id
      pp = nil
      case card_program
        when CardProgram.id_for(:expense)
          pp = PaymentPurpose.id_for(:advance)
        when CardProgram.id_for(:medical)
          pp = PaymentPurpose.id_for :medical_benefit
        when CardProgram.id_for(:meal)
          pp = PaymentPurpose.id_for :meal_benefit
        when CardProgram.id_for(:reimbursement)
          pp = PaymentPurpose.id_for :reimbursement
        else
          # do nothing?
      end
      payment_order.update(payment_purpose_id: pp)
      payment_order.payments.each do |payment|
        payment.update(payment_purpose_id: pp)
        payment.finly_transactions.each do |ft|
          ft.update(payment_purpose_id: pp)
        end
      end
    end
  end
end
