class Expense::Reimbursable::Unmark < Expense::Base

  attr_accessor :selected_expense

  def authorized_user_types
    [:employee]
  end

  def init
    id = params[:id] || params[:expense_id]
    self.selected_expense = user.expenses.find_by(id: id)
  end

  def validate
    unless selected_expense.unreported?
      add_message :error, "This expense cannot be edited at this stage"
      return
    end
    if selected_expense.card_expense?
      add_message :error, "Card expenses are non-reimbursable by default"
      return
    end
    unless selected_expense.reimbursable
      add_message :error, "This expense is already marked as non-reimbursable"
    end
  end

  def process
    unless selected_expense.update(reimbursable: false)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Expense marked as non-reimbursable"
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end