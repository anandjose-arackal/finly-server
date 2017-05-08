# operation that marks a particular expense as a personal expense

class Expense::MarkAsPersonal < Expense::Base

  attr_accessor :selected_expense

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
      unless user.balance_sheet.add_cash_in_hand(selected_expense.amount_value)
        add_message :error, "Could not add cash on hand. Please try again"
        selected_expense.update(personal: false)
      end
    end
    add_message :success, "Expense marked as personal"
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end