class MoveUnaccountedCashOnHandDataToModel < ActiveRecord::Migration
  def change
    Payment.where(payment_purpose_id: PaymentPurpose.id_for(:atm_withdrawal)).where(receiving_account_id: nil).all.each do |payment|

      receiving_account = payment.receiving_user.cash_on_hand
      payment.update(receiving_account: receiving_account)

      # creating a finly transaction first
      next unless payment.completed? or payment.failed? or payment.processing?
      next unless payment.initiating_account.present? or payment.receiving_account.present?

      company_id = (payment.receiving_user&.company_id rescue nil)

      if payment.completed? or payment.processing?
        status_id = TransactionStatus.id_for(:success)
      else
        status_id = TransactionStatus.id_for(:failure)
      end
      credit_account = payment.receiving_account
      if credit_account.present?
        credit_params = {
            finly_account: credit_account,
            transaction_type_id: TransactionType.id_for(:credit),
            amount_attributes: {
                value: payment.amount.value,
                currency_id: payment.amount.currency_id
            },
            status_id: status_id,
            payment_purpose_id: payment.payment_purpose_id,
            opening_balance: nil,
            closing_balance: nil,
            associated_transaction: payment.reference_resource,
            payment: payment,
            company_id: company_id,
            date: payment.date
        }
        t = FinlyTransaction.create credit_params
        unless t.valid?
          raise "#{t.errors.full_messages}"
        end
      end
    end

  end
end
