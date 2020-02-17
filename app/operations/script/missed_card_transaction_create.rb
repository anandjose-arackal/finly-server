class Script::MissedCardTransactionCreate < BaseOperation
  attr_accessor :card, :card_owner, :type, :mode, :transaction, :transaction_status

  def authorized_user_types

  end

  def initialize(params, messages = {})
    self.params = params
    self.messages = messages
  end

  def init

    self.card = Card.find_by(proxy: params[:serial_id])
    self.user = self.card.user rescue nil
    self.type = params[:transaction_type].upcase rescue nil
    self.mode = params[:transaction_mode].upcase rescue nil
    self.transaction = CardTransaction.find_by(reference_id: params[:reference_id], type_of_details: params[:type_of_details])
    params[:user_id] = user.id if user
    params[:card_id] = card.id if card
  end

  def authorize
    unless card and user
      add_message :error, 'Card or User not found in the system'
    end

  end

  def validate
  end

  def pre_process
    unless self.transaction
      # create a transaction out of it
      self.transaction = CardTransaction.new(params)
      unless transaction.save
        add_message :error, transaction.errors.full_messages
        return false
      end
    end
  end

  def process
    case type
    when 'DEBIT'
      case mode
      when 'POS', 'ECOM'

        if self.transaction.card_expense.blank?
          return true unless card.card_program.create_expense

          # create the associated card expense for this transaction
          @result = Expense::ExCard::Create.(transaction, card)
          unless @result.success?
            add_message :error, @result.messages[:error]
            transaction.expensed = false
            transaction.error_message = @result.messages[:error]
            transaction.save
            return false
          end
          transaction.card_expense = @result.expense.card_expense
          transaction.expensed = true
          transaction.save
          return true
        end

      when 'ATM'
        # first check if it's the withdrawal transaction or the surcharge transaction for ATM withdrawals
        if self.transaction && params[:type_of_details] == 'F'
          if self.transaction.card_expense.blank?

            return true unless card.card_program.create_expense
            # add the associated surcharge as a card expense
            @result = Expense::ExCard::Create.(transaction, card)
            unless @result.success?
              add_message :error, @result.messages[:error]
              transaction.expensed = false
              transaction.error_message = @result.messages[:error]
              transaction.save
              return false
            end
            # adding a system message to the card expense indicating that it was a surcharge
            system_message = @result.expense.system_messages.build(system_message_type_id: SystemMessageType.id_for(:info), content: "This expense is an ATM surcharge incurred while withdrawing money").save
            ###############################################################################

            transaction.card_expense = @result.expense.card_expense
            transaction.expensed = true
            transaction.save
          end
        elsif params[:type_of_details] == 'F'
          if self.transaction && params[:type_of_details] == 'F'
            # Check if expense can be created for the card program
            return true unless card.card_program.create_expense

            # add the associated surcharge as a card expense
            @result = Expense::ExCard::Create.(transaction, card)
            unless @result.success?
              add_message :error, @result.messages[:error]
              transaction.expensed = false
              transaction.error_message = @result.messages[:error]
              transaction.save
              return false
            end
            # adding a system message to the card expense indicating that it was a surcharge
            system_message = @result.expense.system_messages.build(system_message_type_id: SystemMessageType.id_for(:info), content: "This expense is an ATM fees incurred while using the ATM").save
            ################################################################################

            transaction.card_expense = @result.expense.card_expense
            transaction.expensed = true
            transaction.save
          end
        elsif params[:type_of_details] == 'T' || params[:type_of_details] == 'S'
          # i.e. it's the actual amount withdrawn to cash on hand, so add it accordingly
          return true if params[:type_of_details] == 'S' && params[:product_code] != 'HDFFRG'

          # add to cash on hand only if it's an expense card

          return true unless card.card_program.create_expense
          payment = Payment.where(reference_resource_id: transaction.id, reference_resource_type: 'CardTransaction', receiving_account_type: 'UserPocket', payment_type_id: 19).first
          if payment.blank?
            # add to cash on hand
            atm_pocket = user.user_pockets.atm_withdrawal_pockets.first
            payment_request = PaymentRequest.(user, nil, UserPocket.name, :credit, :atm_withdrawal)
            payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, atm_pocket, transaction.transaction_amount_value, reference_resource: self.transaction))
            op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
            if op.success?
              return true
            else
              add_message :error, "Could not add credited amount to cash on hand"
              transaction.expensed = false
              transaction.error_message = op.messages[:error]
              transaction.save
              return false
            end
          end
        else
          # it's just an acknowledgement of the transaction being settled, so create a transaction
          # and leave it at that
          if self.transaction.blank?
            self.transaction = CardTransaction.new(params)

            unless transaction.save
              add_message :error, transaction.errors.full_messages
              return false
            end
          end
        end
      else
        # In this case it's a manual debit not belonging to either a manual debit ot credit triggered on Finly, so create a card transaction and a finly transaction
        if transaction.blank?
          self.transaction = CardTransaction.new(params)
          unless transaction.save
            add_message :error, transaction.errors.full_messages
            return false
          end
        end
      end
    when 'CREDIT'
      case mode
      when 'ATM'
        # handling the case of ATM reversals here, where the type of details will be 'R'
        if self.transactrion && params[:type_of_details] == 'R'

          # check if the card is even an expense card at this point
          return true unless card.card_program.create_expense

          # deduct cash on hand
          payment = Payment.where(reference_resource_id: self.transaction.id, reference_resource_type: 'CardTransaction', receiving_account_type: 'UserPocket', payment_type_id: 19).first
          if payment.blank?
            atm_pocket = user.user_pockets.atm_withdrawal_pockets.first
            payment_request = PaymentRequest.(user, nil, UserPocket.name, :debit, :cash_on_hand_reversal)
            payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, atm_pocket, transaction.transaction_amount_value, reference_resource: self.transaction))
            op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)

            if op.success?
              return true
            else
              add_message :error, op.messages[:error]
              transaction.expensed = false
              transaction.error_message = op.messages[:error]
              transaction.save
              return false
            end
          end
        elsif self.transcation && params[:type_of_details] == 'RF'
          # handle the cancellation of the ATM surcharge fee expense that is created during the original card swipe at the ATM
          original_transaction = CardTransaction.find_by(reference_id: params[:reference_id], type_of_details: 'F')
          orig_sur_card_exp = CardExpense.find_by(card_transaction_id: original_transaction&.id)
          original_surcharge_expense = orig_sur_card_exp&.expense
          if original_surcharge_expense.present? && orig_sur_card_exp.present? && orig_sur_card_exp.cancelled = true
            if original_surcharge_expense.present?
              if orig_sur_card_exp.update(cancelled: true)
                self.transaction.update(cancelled: true, cancelled_against_expense_id: orig_sur_card_exp.id)
              else
                add_message :error, orig_sur_card_exp.errors.full_messages
                return
              end
            end
          end
        end
      else
        # just save the transaction for now
        if self.transaction.blank?
          self.transaction = CardTransaction.new(params)
          unless transaction.save
            add_message :error, transaction.errors.full_messages
          end
        end
      end
      # gets added to user's card balance, so do nothing
    else
      # create a vanilla transaction out of it for future reference
      if self.transaction.blank?
        self.transaction = CardTransaction.new(params)
        unless transaction.save
          add_message :errors, transaction.errors.full_messages
        end
      end
    end

  end

  def post_process
    # Create Finly Transaction
    if self.transaction.present? and transaction.success? and not ['Branch TopUp', 'Balance Adjustment Debit'].include?(self.transaction.merchant_name)
      if FinlyTransaction.where(associated_transaction_id: transaction.id, associated_transaction_type: 'CardTransaction').first.nil?
        account = self.transaction.card
        if transaction.credit?
          transaction_type_id = TransactionType.id_for(:credit)
        else
          transaction_type_id = TransactionType.id_for(:debit)
        end
        purpose_id = PaymentPurpose.id_for(:card_transaction)
        amount = transaction.billing_amount
        if transaction.transaction_mode == 'ATM'
          if type == "CREDIT"
            amount = transaction.transaction_amount
            purpose_id = PaymentPurpose.id_for(:cash_on_hand_reversal)
          elsif type == "DEBIT"
            amount = transaction.transaction_amount
            purpose_id = PaymentPurpose.id_for(:atm_withdrawal)
          end
        end
        closing_balance = nil
        bal_check = AccountManager::Balance::Check.(account)
        if bal_check&.success?
          closing_balance = Amount.new(value: bal_check.balance, currency_id: Currency.id_for(:INR))
        end
        ft_params = {
            finly_account: account,
            transaction_type_id: transaction_type_id,
            amount_attributes: {
                value: amount.value,
                currency_id: amount.currency_id
            },
            status_id: TransactionStatus.id_for(:success),
            payment_purpose_id: purpose_id,
            opening_balance: nil,
            closing_balance: closing_balance,
            associated_transaction: transaction,
            payment: nil,
            company_id: transaction.user.company_id,
            date: transaction.transaction_timestamp
        }
        transaction = account.finly_transactions.create ft_params
        unless transaction.valid?
          raise "#{transaction.errors.full_messages}"
        end
      end
    end

    # trigger auto reload of the card to match the amount in the config - IF the user has auto reload configuration enabled
    if type == 'DEBIT' && %w(POS ATM ECOM).include?(mode) && user.auto_reload_config.enabled
      # check if auto reload needs to be performed for this particular card
      card_balance_value = ItzCash::AccountDetails.(user, {card: card}).balance rescue 0
      if user.auto_reload_config.enabled && user.auto_reload_config.target_balance_value > card_balance_value
        result = User::Wallet::AutoReload::Reload.call_async(user.id, {card_id: card.id})
      end
    end
  end
end
