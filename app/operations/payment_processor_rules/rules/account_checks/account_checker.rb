PaymentProcessorRules::Checker.new 'AccountChecker' do


  premise :validate_account_consistency do
    rule 'Receiving accounts inside an order should all be of the same type' do
      payment_order = params[:payment_order]
      crediting_payments = params[:crediting_payments]
      homogenous_accounts = true
      initiating_account_type = payment_order.payments.first.initiating_account_type
      receiving_account_type = payment_order.payments.first.receiving_account_type
      payments = (crediting_payments.present? && !crediting_payments&.empty?) ? crediting_payments : payment_order.payments
      payments.each do |payment|
        unless payment.receiving_account_type == receiving_account_type
          payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                        content: 'Receiving account type has to be same for all transfers').save
          homogenous_accounts = false
        end
        unless payment.initiating_account_type == initiating_account_type
          payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                        content: 'Initiating account type has to be same for all transfers').save
          homogenous_accounts = false
        end
      end
      homogenous_accounts
    end
  end

end