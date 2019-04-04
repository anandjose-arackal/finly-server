PaymentProcessorRules::Checker.new 'StatusChecker' do

  section 'Inside Payment Processor' do

    premise :check_order_status_is_pending do
      rule 'Payment can only be in Pending State' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        if payment_order.pending?
          message 'Payment order is already being processed'
          fail
        end
        if crediting_payments.pluck(:payment_status_id).uniq != [PaymentStatus.id_for(:pending)]
          message 'Payment order is already being processed'
          fail
        end
      end
    end

    premise :payments_being_credited_immediately do
      rule 'Payment Order and Crediting payments must be in pending state' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        payment_order&.with_lock do
          payment_order.reload # kinda redundant since with_lock already reloads the data
          if payment_order.pending? || payment_order.in_progress?
            message "This payment order is already being processed"
            fail
          else
            payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
            crediting_payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
          end
        end
      end
    end

    premise :payments_being_scheduled_for_later do
      rule 'Payments Order and Crediting being scheduled for later must be moved to scheduled status' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:scheduled))
        if crediting_payments.present?
          crediting_payments.update_all(payment_status_id: PaymentStatus.id_for(:scheduled))
        else
          payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:scheduled))
        end
      end
    end
  end

  section 'Inside Payment Validator' do

  end

  section 'Inside Payment Executor' do

    premise :ensure_payments_are_pending_before_processing do
      rule 'Payments must all be in pending status before processing' do
        payment = params[:payment]
        payment.with_lock do
          payment.reload
          unless [PaymentStatus.id_for(:pending)].include?(payment.payment_status_id)
            payment.system_messages.create(content: "Payment cannot be processed in this state",
                                           system_message_type_id: SystemMessageType.id_for(:error))
            message "Payment cannot be processed in this state"
            fail
          end
          # update payment to in progress
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        end
      end
    end

    premise :check_for_invalid_payment_statuses do
      rule 'Payment cannot be in completed state' do

      end

      rule 'Payment cannot be in '
    end

  end

  section 'Inside Bank account adapter' do

  end

  # this section will basically check if the payment is stuck in pending, or any other
  # irregular state and then triggers mailer or something else
  section 'on completion of payment' do

  end

  section 'Validate Payment with operation' do


  end
end