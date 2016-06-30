class ExpenseService < BaseService

  def initialize(current_user)
    @user = current_user
  end

  def user_expenses
    return nil unless @user
    @user.expenses.includes(:manual_expense)
  end

  def add_expense(params=nil)
    return if params.blank?
    expense_params = load_expense_params params
    expense = @user.expenses.build(expense_params)
    if expense.save
      return expense
    else
      errors << expense.errors.full_messages
    end
  end

  def remove_expense(id = nil)
    return if id.blank?
    expense = load_expense id
    if expense.destroy
      return true
    else
      errors << expense.errors.full_messages
    end
  end

  def update_expense(params=nil)
    return if params.blank?
    expense_params = load_expense_params params
    expense = load_expense expense_params[:id]
    if expense.update(expense_params)
      expense.reload
      return expense
    end
    false
  end

  def report_expenses

  end

  # will come in report
  # def reject_expenses(id, memo=nil)
  #   return if id.blank?
  #   expense = load_expense id
  #   return if expense.blank?
  #   # making the expense unsubmitted with the memo
  #   if expense.update(manager_memo: memo, expense_status_id: 1)
  #     return true
  #   else
  #     errors << expense.errors.full_messages
  #   end
  #   false
  # end

  private

  def load_expense_params(params = {})
    expense_params = params[:expense].except(:amount, :currency_id)
    expense_params[:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    if params[:expense][:merchant].present?
      expense_params[:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
      expense_params.delete(:merchant)

    # other conditions based on type of expense can go here
    end
    expense_params
  end

  def load_expense(id)
    @user.expenses.find_by(id: id)
  end
end