class Card::Transaction::Create < BaseOperation

  attr_accessor :card, :card_owner, :type, :mode

  def initialize(params, messages={})
    self.params = params
    self.messages = messages
  end

  def init
    self.card = Card.find_by(proxy: params[:serial_id])
    self.user = self.card.user rescue nil
    self.type = params[:transaction_type]
    self.mode = params[:transaction_mode]
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
      when "Debit"
        case mode
          when "POS"
            # create a transaction out of it
            self.transaction = CardTransaction.create(params)
            unless transaction.save
              messages[:error] = transaction.errors.full_messages
              return false
            end
            # create the associated card expense for this transaction
            @result = Expense::ExCard::Create.(transaction, card)
            unless @result.success?
              messages[:error] = "Transaction not expensed."
              return false
            end
            return true
          when "ATM"
            # add to cash in hand
            unless user.balance_sheet.add_cash_in_hand(params[:transaction_amount_attributes][:value])
              messages[:error] = "Could not add credited amount to cash in hand. Try again"
              return false
            end
          else
            # do nothing
        end
      when "Credit"
        # gets added to user's card balance, so do nothing
      else
        # do nothing
    end

  end

  def post_process
    # send mailer regarding usage of card?
  end

end