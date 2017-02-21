class Card::Transaction::Create < BaseOperation

  attr_accessor :card, :card_owner, :type, :mode, :transaction

  class Card::Transaction::TransactionPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :transaction

    def init
      self.transaction = params[:transaction]
    end

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
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    case type
      when "DEBIT"
        case mode
          when "POS", "ECOM"
            # create a transaction out of it
            self.transaction = CardTransaction.new(params)
            unless transaction.save
              messages[:error] = transaction.errors.full_messages
              return false
            end
            # create the associated card expense for this transaction
            @result = Expense::ExCard::Create.(transaction, card)
            unless @result.success?
              messages[:error] = @result.messages[:error]
              transaction.expensed = false
              transaction.error_message = @result.messages[:error]
              transaction.save
              return false
            end
            transaction.expense = @result.expense
            transaction.save
            return true
          when "ATM"
            # create a transaction out of it
            self.transaction = CardTransaction.new(params)
            unless transaction.save
              messages[:error] = transaction.errors.full_messages
              return false
            end
            # add to cash in hand
            if user.payments.create(amount_attributes: {value: params[:billing_amount_attributes][:value], currency_id: 1},
                                    date: DateUtils.local_date,
                                    payment_type_id: PaymentType.id_for(:atm_withdrawal),
                                    note: "Atm Withdrawal",
                                    initiating_user: user,
                                    receiving_user: user)
              user.balance_sheet.add_cash_in_hand(params[:billing_amount_attributes][:value])
              return true
            else
              messages[:error] = "Could not add credited amount to cash in hand"
              transaction.expensed = false
              transaction.error_message = @result.messages[:error]
              transaction.save
              return false
            end
          else
            # In this case it's a manual debit, so do nothing
        end
      when "CREDIT"
        self.transaction = CardTransaction.new(params)
        unless transaction.save
          messages[:error] = transaction.errors.full_messages
        end
        # gets added to user's card balance, so do nothing
      else
        # do nothing
    end
  end

  def post_process
    # send mailer regarding usage of card?
  end

  def success
    Card::Transaction::TransactionPresenter.new(user, {transaction: transaction}, messages)
  end

end
