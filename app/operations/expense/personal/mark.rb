# operation that marks a particular expense as a personal expense

class Expense::Personal::Mark < Expense::Base

  attr_accessor :selected_expense, :payment_request

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:expense_id]
    self.selected_expense = user.expenses.find_by(id: id)
  end

  def validate
    unless selected_expense
      add_message :error, "Expense not found"
    end

    unless selected_expense.unreported?
      add_message :error, "This expense cannot be marked as personal"
    end

    if selected_expense.personal
      add_message :error, "This expense is already marked as personal"
      return
    end
  end

  def authorize

  end

  def process
    unless selected_expense.update(personal: true)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    # if the expense is a card expense add the amount to cash on hand
    if selected_expense.card_expense?
      # add the amount to cash on hand
      atm_pocket = user.user_pockets.atm_withdrawal_pockets.first
      self.payment_request = PaymentRequest.(user, nil, UserPocket.name, :credit, :personal_expense)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, atm_pocket, selected_expense.amount_value))
      op = AccountManager::Payments::PaymentProcessor.(user, payment_request: self.payment_request)
      unless op.success?
        add_message :error, op.messages[:error]
        selected_expense.update(personal: false)
        return
      end
    end
    add_message :success, "Expense marked as personal"
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end