PaymentProcessorRules::Checker.new 'BalanceChecker' do

  section 'Inside Payment Validator' do

    premise :check_source_account_balance do

      rule 'Source account should be available' do
        payment_order = params[:payment_order]
        source_account_adapter = params[:source_account_adapter]
        options = params[:options] || {}
        unless source_account_adapter.balance(payment_order: payment_order, payment_process: options[:payment_process])
          message "Error retrieving the source account's balance. Try again later"
          fail
        end
      end

      rule 'Source account balance should be more than or equal to order total' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        payment = params[:payment]
        crediting_payments = Payment.with_id(payment&.id) if crediting_payments.blank?

        source_account_adapter = params[:source_account_adapter]
        options = params[:options] || {}
        order_total = crediting_payments.joins(:amount).sum(:value)
        source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
        if order_total > source_account_adapter.balance(payment_order: payment_order, payment_process: options[:payment_process])
          crediting_payments.each do |crediting_payment|
            # If the object exists, i.e only validator is not being called
            if crediting_payment.id.present?
              add_system_message :error, crediting_payment, "#{source_account_adapter.name} has insufficient balance"
            end
          end
          message "You do not have enough balance in #{source_account_name} to make this transfer"
          fail
        end
      end
    end

    premise :check_receiving_account_balance do

      rule 'Receiving account balance should be available' do
        payment_order = params[:payment_order]
        receiving_account_adapter = params[:receiving_account_adapter]
        options = params[:options] || {}
        unless receiving_account_adapter.balance(payment_order: payment_order, payment_process: options[:payment_process])
          message "Error retrieving the source account's balance. Try again later"
          fail
        end
      end

      rule 'The receiving account should have enough balance in case of a debit' do
        payment_order = params[:payment_order]
        crediting_payments = params[:crediting_payments]
        payment = params[:payment]
        crediting_payments = Payment.with_id(payment&.id) if crediting_payments.blank?

        receiving_account_adapter = params[:receiving_account_adapter]
        options = params[:options] || {}
        order_total = crediting_payments.joins(:amount).sum(:value)
        receiving_account_name = receiving_account_adapter.name.is_a?(Array) ? receiving_account_adapter.name.first : receiving_account_adapter.name
        if order_total > receiving_account_adapter.balance(payment_order: payment_order, payment_process: options[:payment_process])
          crediting_payments.each do |crediting_payment|
            # If the object exists, i.e only validator is not being called
            if crediting_payment.id.present?
              add_system_message :error, crediting_payment, "#{receiving_account_adapter.name} has insufficient balance"
            end
          end
          message "You do not have enough balance in #{receiving_account_name} to make this transfer"
          fail
        end
      end

    end
  end

end