  module ManageTransactionDetail
    extend ActiveSupport::Concern

    def save_transaction_detail
       transaction = self

       params = {
           finly_transaction_id: transaction.id,
           transaction_reference_id: transaction.transaction_reference_id,
           transaction_type: transaction.transaction_type.name,
           status: transaction.status&.name,
           amount_id: transaction.amount_id,
           opening_balance_id: transaction.opening_balance_id,
           closing_balance_id: transaction.closing_balance_id,
           company_id: transaction.company_id,
           merchant: merchant(transaction),
           note: transaction.payment&.note,
           payment_purpose: transaction.payment_purpose&.name,
           transaction_date: transaction.date
           # sequence_number: transaction.sequence_number
       }

       if self.transaction_detail.present?
         self.transaction_detail.update(params)
       else
         self.build_transaction_detail(params).save
       end
    end

    def merchant(finly_transaction)
      merchant = ''
      if finly_transaction.credit?
        prefix = 'From '
      else
        prefix = 'To '
      end
      case finly_transaction.payment_purpose_id
      when PaymentPurpose.id_for(:atm_withdrawal), PaymentPurpose.id_for(:personal_expense), PaymentPurpose.id_for(:card_transaction)
        merchant = finly_transaction&.associated_transaction&.merchant_name
      when PaymentPurpose.id_for(:vendor_payment)
        merchant = finly_transaction.payment&.receiving_user&.name
        if merchant.present?
          if finly_transaction.credit?
            merchant = "Reversal for #{merchant}'s Payment"
          elsif finly_transaction.debit?
            merchant = "Sent to #{merchant}"
          end
        else
          merchant = 'Vendor Payment'
        end
      when PaymentPurpose.id_for(:corporate_balance_load)
        merchant = 'Corporate Balance Load'
      when PaymentPurpose.id_for(:corporate_balance_refund)
        refund_payment = finly_transaction.payment
        original_payment = refund_payment.original_payment_for_refund
        original_beneficiary = original_payment&.receiving_user&.name
        merchant = "Refund for #{original_beneficiary}'s payment. Payment ID: #{original_payment.id}" if original_beneficiary.present?
      when PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:reimbursement_outside_finly), PaymentPurpose.id_for(:advance), PaymentPurpose.id_for(:balance_clearance),
          PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:medical_benefit), PaymentPurpose.id_for(:meal_benefit), PaymentPurpose.id_for(:payroll), PaymentPurpose.id_for(:balance_clearance_outside_finly),
          PaymentPurpose.id_for(:cash_advance)
        if finly_transaction.payment.blank?
          if finly_transaction.associated_transaction.class.name == CompanyTransaction.name
            merchant = finly_transaction.associated_transaction.merchant_name
          end
        else
          if finly_transaction.payment.initiating_account == finly_transaction.finly_account and finly_transaction.payment.receiving_account.present?
            merchant = prefix
            merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.receiving_account)}"
          elsif finly_transaction.payment.receiving_account == finly_transaction.finly_account and finly_transaction.payment.initiating_account.present?
            merchant = prefix
            merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.initiating_account)}"
          end
        end
      when PaymentPurpose.id_for(:corporate_account_reload), PaymentPurpose.id_for(:payment_receivable), PaymentPurpose.id_for(:invoice), PaymentPurpose.id_for(:finly_money_reload)
        merchant = "Virtual Account: "
        if finly_transaction.associated_transaction&.virtual_account&.name.present?
          merchant += "#{finly_transaction.associated_transaction&.virtual_account&.name} - "
        end
        merchant += finly_transaction.associated_transaction&.virtual_account&.account_number
      end
      merchant
    end

end