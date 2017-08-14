# operation that marks a particular expense as a personal expense

class Expense::MarkAsPersonal < Expense::Base

  attr_accessor :selected_expense, :payment_request

  def pre_validate

  end

  def init
    id = params[:id] || params[:expense_id]
    self.selected_expense = user.expenses.find_by(id: id)
  end

  def validate
    if selected_expense.personal
      add_message :error, "This expense cannot be marked as personal"
    end
  end

  def process
    unless selected_expense.update(personal: true)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def authorize
    unless selected_expense
      raise_unauthorized_exception
    end
  end

  def post_process
    # if the expense is a card expense add the amount to cash on hand
    if selected_expense.card_expense?
      # add the amount to cash on hand
      self.payment_request = PaymentRequest.(user, nil, CashOnHand.name, :credit, :personal_expense)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, user.cash_on_hand, selected_expense.amount_value))
      op = AccountManager::Payments::PaymentProcessor.(user, payment_request: self.payment_request)
      unless op.success?
        add_message :error, op.messages[:error]
        selected_expense.update(personal: false)
        return
      end
    end
    add_message :success, 'Expense marked as personal'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end