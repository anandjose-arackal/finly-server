# this class will most likely be called from the API class that is consumed by the prepaid
# card provider. The calling class will commit all the data to the Transactions table, and create this expense
# in the Expenses table
# will be initialized with the transaction object and card object that will be passed


class Expense::Card::Create < Expense::Card::Base

  attr_accessor :expense_params

  # overriding initialize because the only info available will be the transaction and card
  def initialize(transaction, card)
    self.errors = []
    self.transaction = transaction
    self.card = card
  end

  def pre_validate
    if transaction.blank? or card.blank?
      errors << "Card or Transaction not present."
    end
    if params[:amount] < 0
      errors << "Amount can't be negative."
    end
  end

  def init
    self.expense_params = card_expense_params
    # extracting the user who owns the card
    self.user = card.user
  end

  def validate
    unless user
      errors << "Card does not belong to any user" # probably indicates a pretty serious problem. todo - deal with ghost card
    end
  end

  def process
    self.expense = user.expenses.build(expense_params)
    unless self.expense.save
      errors << self.expense.errors.full_messages
      return false
    end
    success
  end

  def post_process
    # mailer to user notifying usage of the card - probably can be merged with transaction mailer
  end

  def retrieve
    if is_success?
      return expense
    else
      return false
    end
  end

end