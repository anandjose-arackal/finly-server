class ExpenseService < BaseService

  def initialize(params, current_user)
    @user = current_user
  end

  def user_expenses(user = nil)
    return nil unless user
    @user.expenses.includes(:manual_expense)
  end

  def add_expense(params=nil)
    return if params.blank?
    expense_params = load_expense_params params
    expense = @user.expenses.build(expense_params)
    if expense.save
      true
    else
      errors << expense.errors.full_messages
    end
  end

  def remove_expense(id = nil)
    return if id.blank?
    expense = @user.expenses.find_by(id: id)
    if expense.destroy
      true
    else
      errors << expense.errors.full_messages
    end
  end

  def update_expense(params=nil)

  end

  def report_expenses

  end

  private

  def load_expense_params(params = {})
    expense_params = params[:expense].except!(:amount, :currency)
    expense_params[:amount_attributes] = {value: params[:expense][:amount], currency: params[:expense][:currency]}
  end
end