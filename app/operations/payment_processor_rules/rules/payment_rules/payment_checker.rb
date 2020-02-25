include MathUtil
PaymentProcessorRules::Checker.new 'PaymentChecker' do

  section "Documents cannot have payments that total more than it's total" do

    premise :checking_multiple_payments_against_document do

      rule "Invoices cannot have payments that total more than it's net total" do
        payment = params[:payment]
        if payment.parent_type == "Invoice"
          invoice = payment.parent
          # i.e. includes all payments except the one being considered right now
          successful_payments = invoice.payments.without_id(payment.id).all_except_failed
          processed_amount = successful_payments.joins(:amount).sum(:value).to_f
          if precision_value(processed_amount + payment.amount_value) > precision_value(invoice.balance_due&.value.to_f)
            add_system_message :error, payment, "This payment cannot be processed as the sum total of payments against this invoice exceeds the invoice amount"
            message "This payment cannot be processed as the sum total of payments against this invoice exceeds the invoice amount"
            # also marking the payment as failed here
            payment.update(payment_status_id: PaymentStatus.id_for(:failed))
            fail
          end
        end
      end

      rule "Purchase Order advances cannot have payments that total more than it's net advance" do
        payment = params[:payment]
        if payment.parent_type == "PurchaseOrder"
          purchase_order = payment.parent
          successful_payments = purchase_order.advance_payments.without_id(payment.id).all_except_failed
          processed_amount = successful_payments.joins(:amount).sum(:value).to_f
          if precision_value(processed_amount + payment.amount_value) > precision_value(purchase_order.advance_amount&.value)
            add_system_message :error, payment, "This payment cannot be processed as the sum total of payments against this PO Advance exceeds the PO Advance amount"
            message "This payment cannot be processed as the sum total of payments against this PO Advance exceeds the PO Advance amount"
            # also marking the payment as failed here
            payment.update(payment_status_id: PaymentStatus.id_for(:failed))
            fail
          end
        end
      end
    end
  end

  section 'Duplicate payment check inside the Payments Adapter' do

    premise :ensure_successive_payments_are_not_initiated_within_short_timeframe do

      rule "Payments must not have multiple bank transactions generated within a span of 10 minutes" do
        payment = params[:payment]
        latest_bank_transaction = payment.reference_resources.first # this gives the latest transaction because the reference_resources are returned in descending order of created_at
        if latest_bank_transaction.present? && (DateUtils.local_date_time - latest_bank_transaction.created_at < 10.minutes)
          add_system_message :error, payment, "Payment cannot be processed at the moment as there is another transaction in process for this payment"
          message "Payment cannot be processed at the moment as there is another transaction in process for this payment"
          fail
        end
      end
    end

    premise :ensure_all_previous_transactions_have_failed_before_allowing_retry do

      rule "For a given payment, we need to make sure there are no old bank_transactions that are NOT failed" do
        payment = params[:payment]
        bank_transactions = payment.reference_resources
        # what we're doing below is that unless all previous bank_transactions have a failed or rejected status
        # the API call for this payment shall not happen
        bank_transactions.each do |bank_transaction|

          # TODO - call the common status checker class and update the status of this bank transaction

          unless BankTransferStatus.ids_for(:failed, :rejected).include?(bank_transaction.transfer_status_id)
            add_system_message :error, payment, "Payment cannot be processed as there is a pending transaction for this payment with the bank"
            message "Payment cannot be processed as there is a pending transaction for this payment with the bank"
            payment.update(payment_status_id: PaymentStatus.id_for(:failed))
            fail
          end
        end
      end
    end

    premise :yes_bank_payments_cannot_have_multiple_bank_transactions do

      # the below rule is because yes bank allows multiple retries with the same reference number, a facility not provided by other banks
      rule "For a given YesBank payment, once cannot have more than one bank transaction" do
        payment = params[:payment]
        if payment.reference_resources.count > 1
          add_system_message :error, payment, "Payment cannot be retried at this moment"
          message "Payment cannot be retried at this moment"
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          fail
        end
      end
    end

  end


  section 'Data consistency check inside payment adapter' do

    premise :bank_transaction_must_exist_before_calling_bank_apis do

      rule "Bank Transaction object must exist inside the payments adapter" do
        bank_transaction = params[:bank_transaction]
        payment = params[:payment]
        # i.e. unless this bank transaction has been persisted, it's an error
        unless bank_transaction.persisted?
          payment.system_messages.build(
              content: "Payment cannot be processed at this time - #{bank_transaction.errors.full_messages.to_sentence}",
              system_message_type_id: SystemMessageType.id_for(:error).save
          )
          message "Bank Transaction did not get created inside the adapter - #{bank_transaction.errors.full_messages.to_sentence}"
          fail
        end
      end
    end
  end

end