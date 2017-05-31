class Card::Transaction::Create < BaseOperation
  attr_accessor :card, :card_owner, :type, :mode, :transaction

  class Card::Transaction::TransactionPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :transaction

    def init
      self.transaction = params[:transaction]
    end

  end

  def authorized_user_types

  end

  def initialize(params, messages={})
    self.params = params
    self.messages = messages
  end

  def init
    self.card = Card.find_by(proxy: params[:serial_id])
    self.user = self.card.user rescue nil
    self.type = params[:transaction_type].upcase rescue nil
    self.mode = params[:transaction_mode].upcase rescue nil
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

  def process
    case type
      when 'DEBIT'
        case mode
          when 'POS', 'ECOM'
            # create a transaction out of it
            self.transaction = CardTransaction.new(params)
            unless transaction.save
              add_message :error, transaction.errors.full_messages
              return false
            end

            # Check if expense can be created for the card program
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

          when 'ATM'
            # first check if it's the withdrawal transaction or the surcharge transaction for ATM withdrawals
            if CardTransaction.find_by(reference_id: params[:reference_id])
              # i.e. it's the ATM surcharge, so add it as an expense
              # prepending ATM SURCHARGE to the merchant name for clarity
              params[:merchant_name].insert(0, "ATM SURCHARGE - ") rescue nil
              self.transaction = CardTransaction.new(params)
              unless transaction.save
                add_message :error, transaction.errors.full_messages
                return false
              end

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
            else
              # i.e. it's the actual amount withdrawn to cash on hand, so add it accordingly
              self.transaction = CardTransaction.new(params)
              unless transaction.save
                add_message :error, transaction.errors.full_messages
                return false
              end
              # add to cash on hand
              if user.payments.create(amount_attributes: {value: params[:transaction_amount_attributes][:value], currency_id: Currency.first.id},
                                      date: DateUtils.local_date,
                                      payment_type_id: PaymentType.id_for(:atm_withdrawal),
                                      note: "Atm Withdrawal",
                                      initiating_user: user,
                                      receiving_user: user,
                                      payment_status_id: PaymentStatus.id_for(:completed))
                user.balance_sheet.add_cash_in_hand(params[:transaction_amount_attributes][:value])
                return true
              else
                add_message :error, "Could not add credited amount to cash on hand"
                transaction.expensed = false
                transaction.error_message = @result.messages[:error]
                transaction.save
                return false
              end
            end
          else
            # In this case it's a manual debit, so do nothing
        end
      when 'CREDIT'
        self.transaction = CardTransaction.new(params)
        unless transaction.save
          add_message :error, transaction.errors.full_messages
        end
      # gets added to user's card balance, so do nothing
      else
        # do nothing
    end
  end

  def post_process
    # send mailer regarding usage of card?
    return unless success?
    params = self.params
    params[:transaction] = self.transaction
    Event::ECard::ETransaction::Create.(self.user, params)
    # trigger auto reload of the card to match the amount in the config
    if type == 'DEBIT' && %w(POS ATM ECOM).include?(mode)
      # check if auto reload needs to be performed for this particular card
      card_balance_value = ItzCash::AccountDetails.(user, {card_id: card.id}).balance rescue 0
      if user.auto_reload_config.minimum_balance_value > card_balance_value
        User::Wallet::AutoReload::Reload.call_async(user.id, {card_id: card.id})
      end
    end
  end

  def success
    Card::Transaction::TransactionPresenter.new(user, {transaction: transaction}, messages)
  end

end
