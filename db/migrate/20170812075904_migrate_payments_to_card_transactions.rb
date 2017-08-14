class MigratePaymentsToCardTransactions < ActiveRecord::Migration
  def up
    PaymentPurpose.seed_data
    add_column :finly_transactions, :date, :datetime, index: true
    Company.all.each do |company|
      next unless company.itz_cash_company_account.present?
      company.company_transactions.each do |company_transaction|
        # Ignore card transfers are these transactions would be generated from payments
        next if company_transaction.card_transfer?
        transaction_type = TransactionType.id_for(company_transaction.transaction_type.downcase)
        reference_id = Generator.reference_id_for(company.itz_cash_company_account, nil, nil, company_transaction.transaction_date)
        if company_transaction.transaction_type.downcase == 'debit'
          purpose_id = PaymentPurpose.id_for(:advance)
        else
          if company_transaction.merchant_name.downcase.include?('manual') || company_transaction.merchant_name.downcase.include?('payu')
            purpose_id = PaymentPurpose.id_for(:corporate_balance_load)
          else
            purpose_id = PaymentPurpose.id_for(:balance_clearance)
          end
        end
        closing_balance = company_transaction.balance_amount.value
        if company_transaction.transaction_type.downcase == 'credit'
          opening_balance = (company_transaction.balance_amount.value - company_transaction.transaction_amount.value)
        else
          opening_balance = (company_transaction.balance_amount.value + company_transaction.transaction_amount.value)
        end
        params = {
            transaction_type_id: transaction_type,
            amount_attributes: {
                value: company_transaction.transaction_amount.value,
                currency_id: Currency.id_for(:INR)
            },
            transaction_reference_id: reference_id,
            status_id: TransactionStatus.id_for(:success),
            payment_purpose_id: purpose_id,
            opening_balance: nil,
            closing_balance: nil,
            associated_transaction: company_transaction,
            payment: nil,
            company_id: company.id,
            date: company_transaction.transaction_date
        }
        transaction = company.itz_cash_company_account.finly_transactions.create(params)
        unless transaction.valid?
          raise "#{transaction.errors.full_messages}"
        end
      end
    end

    Payment.all.each do |payment|
      next unless payment.completed? or payment.failed? or payment.processing?
      next unless payment.initiating_account.present? or payment.receiving_account.present?

      company_id = (payment.receiving_user&.company_id rescue nil)
      if company_id.blank?
        company_id = (payment.receiving_account&.user.company_id rescue nil)
      end
      if company_id.blank?
        company_id = (payment.receiving_account&.company_id rescue nil)
      end
      if payment.completed? or payment.processing?
        status_id = TransactionStatus.id_for(:success)
      else
        status_id = TransactionStatus.id_for(:failure)
      end
      credit_account = nil
      debit_account = nil
      if payment.credit?
        debit_account = payment.initiating_account
        credit_account = payment.receiving_account
      elsif payment.debit?
        credit_account = payment.initiating_account
        debit_account = payment.receiving_account
      end
      if credit_account.present?
        credit_params = {
            finly_account: credit_account,
            transaction_type_id: TransactionType.id_for(:credit),
            amount_attributes: {
                value: payment.amount.value,
                currency_id: payment.amount.currency_id
            },
            transaction_reference_id: payment.reference_id,
            status_id: status_id,
            payment_purpose_id: payment.payment_purpose_id,
            opening_balance: nil,
            closing_balance: nil,
            associated_transaction: payment.reference_resource,
            payment: payment,
            company_id: company_id,
            date: payment.date
        }
        t = FinlyTransaction.create credit_params
        unless t.valid?
          raise "#{t.errors.full_messages}"
        end
      end
      if debit_account.present?
        debit_params = {
            finly_account: debit_account,
            transaction_type_id: TransactionType.id_for(:debit),
            amount_attributes: {
                value: payment.amount.value,
                currency_id: payment.amount.currency_id
            },
            transaction_reference_id: payment.reference_id,
            status_id: status_id,
            payment_purpose_id: payment.payment_purpose_id,
            opening_balance: nil,
            closing_balance: nil,
            associated_transaction: payment.reference_resource,
            payment: payment,
            company_id: company_id,
            date: payment.date
        }
        t = FinlyTransaction.create debit_params
        unless t.valid?
          raise "#{t.errors.full_messages}"
        end
      end
    end

    Expense.all.only_card_expenses.personal.each do |expense|
      cash_on_hand = expense.user.cash_on_hand
      cash_on_hand_params = {
          finly_account: cash_on_hand,
          transaction_type_id: TransactionType.id_for(:credit),
          amount_attributes: {
              value: expense.amount.value,
              currency_id: expense.amount.currency_id
          },
          transaction_reference_id: Generator.reference_id_for(cash_on_hand, nil, expense.amount.value, expense.date),
          status_id: TransactionStatus.id_for(:success),
          payment_purpose_id: PaymentPurpose.id_for(:personal_expense),
          opening_balance: nil,
          closing_balance: nil,
          associated_transaction: expense.card_expense.card_transaction,
          payment: nil,
          company_id: expense.user.company_id,
          date: expense.date
      }
      t = cash_on_hand.finly_transactions.create cash_on_hand_params
      unless t.valid?
        raise "#{t.errors.full_messages}"
      end
    end

    CardTransaction.successful.group(:reference_id, :transaction_type, :type_of_details).each do |transaction|
      if ['Branch TopUp', 'Balance Adjustment Debit'].include?(transaction.merchant_name)
        next
      end
      if transaction.credit?
        transaction_type_id = TransactionType.id_for(:credit)
      else
        transaction_type_id = TransactionType.id_for(:debit)
      end
      account = transaction.card
      purpose_id = PaymentPurpose.id_for(:card_transaction)
      amount = transaction.billing_amount
      if transaction.transaction_mode == 'ATM'
        amount = transaction.transaction_amount
        purpose_id = PaymentPurpose.id_for(:atm_withdrawal)
      end
      params = {
          finly_account: account,
          transaction_type_id: transaction_type_id,
          amount_attributes: {
              value: amount.value,
              currency_id: amount.currency_id
          },
          transaction_reference_id: Generator.reference_id_for(account, nil, amount.value, transaction.transaction_timestamp),
          status_id: TransactionStatus.id_for(:success),
          payment_purpose_id: purpose_id,
          opening_balance: nil,
          closing_balance: nil,
          associated_transaction: transaction,
          payment: nil,
          company_id: transaction.user.company_id,
          date: transaction.transaction_timestamp
      }
      t = account.finly_transactions.create params
      unless t.valid?
        raise "#{t.errors.full_messages}"
      end
    end

  end
end
