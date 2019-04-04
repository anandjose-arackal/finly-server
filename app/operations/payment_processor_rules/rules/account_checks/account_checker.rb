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
            add_system_message :error, payment, 'Receiving account type has to be same for all transfers'
            homogenous_accounts = false
          end
          unless payment.initiating_account_type == initiating_account_type
            add_system_message :error, payment, 'Initiating account type has to be same for all transfers'
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
        options = params[:options]
        unless source_account_adapter.balance(payment_order: payment_order, payment_process: options[:payment_process])
          #todo - add system messages to payments?
          message "Error retrieving the source account's balance. Try again later"
          fail
        end
      end

      rule 'Source account balance should be more than or equal to order total' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        source_account_adapter = params[:source_account_adapter]
        options = params[:options]
        order_total = crediting_payments.joins(:amount).sum(:value)
        source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
        if order_total > source_account_adapter.balance(payment_order: payment_order, payment_process: options[:payment_process])
          crediting_payments.each do |payment|
            # If the object exists, i.e only validator is not being called
            if payment.id.present?
              add_system_message :error, payment, "#{source_account_adapter.name} has insufficient balance"
            end
          end
          message "You do not have enough balance in #{source_account_name} to make this transfer"
          fail
        end
      end
    end

    premise :check_receiving_account_balance do

      rule 'The receiving account should have enough balance in case of a debit' do
        crediting_payments = params[:crediting_payments]
        valid = true
        crediting_payments.each do |payment|
          receiving_account_adapter = retrieve_adapter payment.receiving_account
          unless receiving_account_adapter.balance >= payment.amount_value
            valid = false
            # If the object exists, i.e only validator is not being called
            if payment.id.present?
              add_system_message :error, payment, "#{receiving_account_adapter.name} has insufficient balance"
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

    premise :check_receiving_account_creditable do

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
          Event::EAlert::Create.(nil, title: 'Payment attempted for on hold account', description: "Payment attempted for on hold account. Details: #{payment.as_json}", subject: 'Payment attempted for on hold account')
          message "Transfers to this account have been temporarily put on hold"
          fail
        end
      end

    end

    premise :check_source_account_debitable do

      rule 'Source account should be debitable from the initiating account' do
        payment = params[:payment]
        source_account_adapter = params[:source_account_adapter]
        receiving_account_adapter = params[:receiving_account_adapter]
        receiving_account_name = receiving_account_adapter.name.is_a?(Array) ? receiving_account_adapter.name.first : receiving_account_adapter.name
        source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
        unless source_account_adapter.debitable_account?(payment.receiving_account)
          add_system_message :error, payment, "You cannot credit from #{source_account_name} to #{receiving_account_name}"
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          message 'You cannot debit from this account'
          fail
        end
      end

    end

  end


end