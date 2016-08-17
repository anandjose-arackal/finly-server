# the class that will create an entry in the transactions table after card provider
# consumes our api upon a card transaction

# A few assumptions here:
# - the card proxy id will be provided to correlate with our db
# - all the parameters will be passed in one call

class API::CardTransaction::Create < CardTransaction::Base

  attr_accessor :transaction_params, :card_transaction

  def initialize(params)
    self.params = params
  end


  def pre_validate
    if params.blank?
      errors << "Params are empty."
    end
  end

  def init
    self.card = Card.find_by(proxy: params[:proxy])
    self.user = card.user

    # todo - will whitelist all the parameters once they're decided
    params.permit!
  end

  def authorize
    # todo - can't think of any authorization atm
  end

  def process
    self.card_transaction = user.card_transactions.build(params)
    unless card_transaction.save
      errors << "Error creating the trasnaction."
    end
  end

  # calling the card expense class to create a card expense based on these details
  def post_process
    card_expense_create = Expense::Card::Create.new(card_transaction, card)
    unless card_expense_create.run
      errors << "Card expense not created."
    end

    # notify user about card having been used
  end
end