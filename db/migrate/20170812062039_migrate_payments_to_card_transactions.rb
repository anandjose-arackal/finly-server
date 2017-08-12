class MigratePaymentsToCardTransactions < ActiveRecord::Migration
  def change
    Payment.all.each do |payment|
      next unless payment.completed? or payment.failed? or payment.processing?
      credit_account = nil
      debit_account = nil
      if payment.completed?
        status_id = TransactionStatus.id_for(:success)
      elsif payment.failed?
        status_id = TransactionStatus.id_for(:failure)
      else
        status_id = TransactionStatus.id_for(:processing)
      end
      if payment.credit?
        debit_account = payment.initiating_account
        credit_account = payment.receiving_account
      elsif payment.debit?
        credit_account = payment.initiating_account
        debit_account = payment.receiving_account
      end
      if credit_account != nil
        credit_params = {
            finly_account: credit_account,
            transaction_type_id: TransactionType.id_for(:credit),
            amount_attributes: {
                value: payment.amount.value,
                currency_id: payment.amount.currency_id
            },
            transaction_reference_id: payment.transaction_reference_id,
            status_id:
        }
      end
    end
  end
end
