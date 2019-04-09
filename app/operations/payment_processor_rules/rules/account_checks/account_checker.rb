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

  end

  section 'Inside Payment Executor' do

    premise :check_receiving_account_creditable do

      rule 'Check if the receiving account is creditable from the source account' do
        payment = params[:payment]
        source_account_adapter = params[:source_account_adapter]
        receiving_account_adapter = params[:receiving_account_adapter]
        receiving_account_name = receiving_account_adapter.name.is_a?(Array) ? receiving_account_adapter.name.first : receiving_account_adapter.name
        source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
        unless receiving_account_adapter.creditable_account?(payment.initiating_account)
          add_system_message :error, payment, "You cannot credit from #{source_account_name} to #{receiving_account_name}"
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          message 'You cannot debit from this account'
          fail
        end
      end

      rule 'Receiving account should not be blacklisted / disabled' do
        payment = params[:payment]
        # checking to see if the receiving account is a bank account if it has been disabled by any chance
        if payment.receiving_account.is_a?(BankAccount) && payment.receiving_account.disabled?
          payment.update(disabled: true, payment_status_id: PaymentStatus.id_for(:failed))
          add_system_message :error, payment, "You cannot make transfers to this bank account as it has been blacklisted"
          message "You cannot make transfers to this bank account as it has been blacklisted"
          fail
        end
      end

      rule 'Receiving account should not be on hold' do
        payment = params[:payment]
        if payment.receiving_account.is_a?(BankAccount) && payment.receiving_account.on_hold?
          add_system_message :error, payment, "Transfers to this account have been temporarily put on hold"
          payment.update(on_hold: true, payment_status_id: PaymentStatus.id_for(:failed))
          # Event::EAlert::Create.(nil, title: 'Payment attempted for on hold account', description: "Payment attempted for on hold account. Details: #{payment.as_json}", subject: 'Payment attempted for on hold account')
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