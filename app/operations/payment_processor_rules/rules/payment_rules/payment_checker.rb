include MathUtil
PaymentProcessorRules::Checker.new 'PaymentChecker' do

  section "Documents cannot have payments that total more than it's total" do

    premise :checking_multiple_payments_against_document do

      rule "Invoices cannot have payments that total more than it's net total" do
        payment = params[:payment]
        if payment.parent_type == "Invoice"
          invoice = payment.parent
          successful_payments = invoice.payments.all_except_failed
          processed_amount = successful_payments.joins(:amount).sum(:value).to_f
          if precision_value(processed_amount + payment.amount_value) > precision_value(invoice.balance_due&.value.to_f)
            add_system_message :error, payment, "This payment cannot be processed as the sum total of payments against this invoice exceeds the invoice amount"
            message "This payment cannot be processed as the sum total of payments against this invoice exceeds the invoice amount"
            fail
          end
        end
      end

      rule "Purchase Order advances cannot have payments that total more than it's net advance" do
        payment = params[:payment]
        if payment.parent_type == "PurchaseOrder"
          purchase_order = payment.parent
          successful_payments = purchase_order.advance_payments.all_except_failed
          processed_amount = successful_payments.joins(:amount).sum(:value).to_f
          if precision_value(processed_amount + payment.amount_value) > precision_value(purchase_order.advance_amount&.value)
            add_system_message :error, payment, "This payment cannot be processed as the sum total of payments against this PO Advance exceeds the PO Advance amount"
            message "This payment cannot be processed as the sum total of payments against this PO Advance exceeds the PO Advance amount"
            fail
          end
        end
      end
    end
  end

  section 'Duplicate check inside the Payments Adapter' do

    premise :ensure_successive_payments_are_not_initiated_within_short_timeframe do

      rule "Payments must not have multiple bank transactions generated within a span of 10 minutes" do
        payment = params[:payment]
        bank_transactions = payment.reference_resources
        first_bank_transaction = payment.reference_resources.first
        if bank_transactions.count > 1
          first_created_at = first_bank_transaction.created_at
          bank_transactions.without_id(first_bank_transaction.id).each do |bank_transaction|
            if bank_transaction.created_at - first_created_at > 10.minutes
              add_system_message :error, payment, "Payment cannot be processed at the moment as there is another transaction in process for this payment"
              message "Payment cannot be processed at the moment as there is another transaction in process for this payment"
              fail
            end
            first_created_at = bank_transaction.created_at
          end
        end
      end
    end

    premise :ensure_all_previous_transactions_have_failed_before_allowing_retry do
      rule "For a given payment, we need to make sure there are no old bank_transactions that are NOT failed" do
        payment = params[:payment]
        bank_transactions = payment.reference_resources
        # what we're doing below is that unless all previous bank_transactions have a failed or rejected status
        # the API call for this payment shall not happen
        if bank_transactions.present?
          unless bank_transactions.pluck(:transfer_status_id).uniq.sort == BankTransferStatus.ids_for(:failed, :rejected)
            add_system_message :error, payment, "Payment cannot be processed as there is a pending transaction for this payment with the bank"
            message "Payment cannot be processed as there is a pending transaction for this payment with the bank"
            fail
          end
        end
      end
    end
  end

end