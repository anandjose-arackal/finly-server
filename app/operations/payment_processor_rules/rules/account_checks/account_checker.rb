PaymentProcessorRules::Checker.new 'AccountChecker' do

  section 'Inside Payment Validator' do
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

    premise :check_source_account_balance do

      rule 'Source account should be available' do
        payment_order = params[:payment_order]
        source_account_adapter = params[:source_account_adapter]
        unless source_account_adapter.balance(payment_order: payment_order, payment_process: self.options[:payment_process])
          #todo - add system messages to payments?
          message "Error retrieving the source account's balance. Try again later"
          fail
        end
      end

      rule 'Source account balance should be more than or equal to order total' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        source_account_adapter = params[:source_account_adapter]
        order_total = crediting_payments.joins(:amount).sum(:value)
        source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
        if order_total > source_account_adapter.balance(payment_order: payment_order, payment_process: self.options[:payment_process])
          crediting_payments.each do |payment|
            # If the object exists, i.e only validator is not being called
            if payment.id.present?
              payment.system_messages.build(content: "#{source_account_adapter.name} has insufficient balance",
                                            system_message_type_id: SystemMessageType.id_for(:error)).save
            end
          end
          message "You do not have enough balance in #{source_account_name} to make this transfer"
          fail
        end
      end
    end

    premise :check_balance_of_receiving_account do

      rule 'The receiving account should have enough balance in case of a debit' do
        crediting_payments = params[:crediting_payments]
        valid = true
        crediting_payments.each do |payment|
          receiving_account_adapter = retrieve_adapter payment.receiving_account
          unless receiving_account_adapter.balance >= payment.amount_value
            valid = false
            # If the object exists, i.e only validator is not being called
            if payment.id.present?
              payment.system_messages.build(content: "#{receiving_account_adapter.name} has insufficient balance",
                                            system_message_type_id: SystemMessageType.id_for(:error)).save
            end
          end
        end
        unless valid
          message "There isn't enough balance in the source account for this transaction"
          fail
        end
      end

    end
  end

  section 'Inside Payment Executor' do

    premise :check_receiving_account_is_creditable do

      rule 'Receiving account should not be blacklisted' do
        payment = params[:payment]
        # checking to see if the receiving account is a bank account if it has been disabled by any chance
        if payment.receiving_account.is_a?(BankAccount) && payment.receiving_account.disabled?
          add_system_message :error, payment, "You cannot make transfers to this bank account as it has been blacklisted"
          message "You cannot make transfers to this bank account as it has been blacklisted"
          fail
        end
      end

      rule 'Receiving account should not be on hold' do
        payment = params[:payment]
        if payment.receiving_account.is_a?(BankAccount) && payment.receiving_account.on_hold?
          add_system_message :error, payment, "Transfers to this account have been temporarily put on hold"
          Event::EAlert::Create.(nil, title: 'Payment attempted for on hold account', description: "Payment attempted for on hold account. Details: #{self.payment.as_json}", subject: 'Payment attempted for on hold account')
          message "Transfers to this account have been temporarily put on hold"
          fail
        end
      end

    end

  end


end