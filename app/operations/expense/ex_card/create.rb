# this class will most likely be called from the API class that is consumed by the prepaid
# card provider. The calling class will commit all the data to the Transactions table, and create this expense
# in the Expenses table
# will be initialized with the transaction object and card object that will be passed

class Expense::ExCard::Create < Expense::ExCard::Base
  attr_accessor :expense_params

  # overriding initialize because the only info available will be the transaction and card
  def initialize(transaction, card)
    self.messages = []
    self.transaction = transaction
    self.card = card
    self.user = card.user if card
    self.params = ActionController::Parameters.new(params)
  end

  def pre_validate
    if transaction.blank? or card.blank?
      messages[:error] << "Card or Transaction not present."
    end
  end

  def init
    self.expense_params = card_expense_params
    # extracting the user who owns the card
    self.user = card.user
  end

  def validate
    unless user
      messages[:error] << "Card does not belong to any user" # probably indicates a pretty serious problem. todo - deal with ghost card
    end
  end

  def process
    self.expense = user.expenses.build(expense_params)
    unless self.expense.save
      messages[:error] = self.expense.errors.full_messages
      return false
    end
    success
  end

  def post_process
    # mailer to user notifying usage of the card - probably can be merged with transaction mailer
  end

  private
  # this will be called when the expense is being created - i.e. the moment the card is used, parameters will be created from the transaction object
  def card_expense_params
    currency_id = Currency.find_by(country_code: transaction[:transaction_currency_code]).id

    currency_id = create_new_currency(transaction[:transaction_currency_code]) if currency_id.nil?

    params[:amount_attributes] = {value: transaction.transaction_amount_value, currency_id: currency_id}
    params[:card_expense_attributes] = {editable_merchant: transaction[:merchant_name]} if transaction[:merchant_name]
    params[:expense_type_id] = ExpenseType.card_expense_id
    params[:expense_status_id] = ExpenseStatus.unreported_id
    params[:date] = transaction[:date]

    # todo - temporary, category will be extracted from the mcc-category mapping henceforth
    params[:category_id] = 1
    #######################################################################################

    params.permit(:expense_type_id, :expense_status_id, :note, :category_id, :date,
                  amount_attributes: [:value, :currency_id],
                  card_expense_attributes: [:editable_merchant])
  end

  def create_new_currency(currency_code)
    new_curr = Currency.create!(country_code: currency_code)
    new_curr.id
  end


end