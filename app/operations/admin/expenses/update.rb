# for now will handle all manual expense updates - can be generalized to other types based on requirement

class Admin::Expenses::Update < Admin::Expenses::Base

  attr_accessor :expense, :expense_update_params

  def pre_validate

  end

  def init
    id = params[:id] || params[:expense_id]
    self.expense = Expense.find_by(id: id)
    self.expense_update_params = expense_params

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