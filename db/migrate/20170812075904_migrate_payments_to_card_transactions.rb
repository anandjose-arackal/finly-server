class MigratePaymentsToCardTransactions < ActiveRecord::Migration
  def change
    Payment.all.each do |payment|
      next unless payment.completed? or payment.failed? or payment.processing?
      next unless payment.initiating_account.present? or payment.receiving_account.present?

      company_id = (payment.receiving_user&.company_id rescue nil)
      if company_id.blank?
        company_id = (payment.receiving_account&.user.company_id rescue nil)
      end
      if company_id.blank?
        company_id = (payment.receiving_account&.company_id rescue nil)
      end
      if payment.completed? or payment.processing?
        status_id = TransactionStatus.id_for(:success)
      else
        status_id = TransactionStatus.id_for(:failure)
      end
      credit_account = nil
      debit_account = nil
      if payment.credit?
        debit_account = payment.initiating_account
        credit_account = payment.receiving_account
      elsif payment.debit?
        credit_account = payment.initiating_account
        debit_account = payment.receiving_account
      end
      if credit_account.present?
        credit_params = {
            finly_account: credit_account,
            transaction_type_id: TransactionType.id_for(:credit),
            amount_attributes: {
                value: payment.amount.value,
                currency_id: payment.amount.currency_id
            },
            transaction_reference_id: payment.reference_id,
            status_id: status_id,
            payment_purpose_id: payment.payment_purpose_id,
            opening_balance: nil,
            closing_balance: nil,
            associated_transaction: payment.reference_resource,
            payment: payment,
            company_id: company_id,
            created_at: payment.date
        }
        t = FinlyTransaction.create credit_params
        unless t.valid?
          raise "#{t.errors.full_messages}"
        end
      end
      if debit_account.present?
        debit_params = {
            finly_account: credit_account,
            transaction_type_id: TransactionType.id_for(:debit),
            amount_attributes: {
                value: payment.amount.value,
                currency_id: payment.amount.currency_id
            },
            transaction_reference_id: payment.reference_id,
            status_id: status_id,
            payment_purpose_id: payment.payment_purpose_id,
            opening_balance: nil,
            closing_balance: nil,
            associated_transaction: payment.reference_resource,
            payment: payment,
            company_id: company_id,
            created_at: payment.date
        }
        t = FinlyTransaction.create debit_params
        unless t.valid?
          raise "#{t.errors.full_messages}"
        end
      end
    end
  end
end
