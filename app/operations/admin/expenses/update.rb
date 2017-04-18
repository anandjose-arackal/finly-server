# for now will handle all manual expense updates - can be generalized to other types based on requirement

class Admin::Expenses::Update < Admin::Expenses::Base

  attr_accessor :expense, :expense_update_params

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:expense_id]
    self.expense = Expense.find_by(id: id)
    self.expense_update_params = expense_params
  end

  def validate
    unless expense
      add_message :error, "Expense not found"
    end
  end

  def pre_process
    # setting the ids for amount and manual expense so that new objects aren't created every time an expense in updated
    expense_update_params[:manual_expense_attributes][:id] = expense.manual_expense.id
    expense_update_params[:amount_attributes][:id] = expense.amount_id
  end

  def process
    unless expense.update(expense_update_params)
      add_message :error, expense.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Expense Updated"
  end

  def success
    params[:expense] = expense
    Admin::Expenses::Base::ExpensePresenter.new(user, params, messages)
  end
end