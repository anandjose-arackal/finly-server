PaymentProcessorRules::Checker.new 'StatusChecker' do

  section 'Inside Payment Processor' do

    premise :payment_passes_standard_violations do

    end

    premise :check_payment_status_is_pending do
      rule 'Payment can only be in Pending State' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        if payment_order.pending?
          messages ['Payment order is already being processed']
          fail
        end

        # now mark the order as pending and move on
        payment_order.with_lock do
          payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
          crediting_payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
        end
      end
    end
  end

  section 'on credit initiate' do

  end

  section 'on hitting bank account adapter' do

  end

  # this section will basically check if the payment is stuck in pending, or any other
  # irregular state and then triggers mailer or something else
  section 'on completion of payment' do

  end

  section 'Validate Payment with operation' do


  end
end