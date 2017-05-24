class Expense::Manual::IsDuplicate < Expense::Manual::Base
  attr_accessor :expense

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:expense).present?
      add_message :error, 'Expense not found'
      return
    end
  end

  def init
    self.expense = params[:expense]
  end

  def validate
    unless self.expense.present?
      add_message :error, 'Expense not found'
      return
    end
    unless self.expense.manual? and self.expense.manual_expense.present?
      add_message :error, 'Invalid Expense Type'
      return
    end
  end

  def process
    user_expenses = expense.user.expenses
    if expense.report.present? and not expense.report.open?
      user_expenses = user_expenses.submitted
    end
    duplicate_expenses = user_expenses.with_date(expense.date).filter_expense_type_id(expense.expense_type_id).having_amount_currency(expense.amount.value, expense.amount.currency_id)
    duplicate_expense_ids  = duplicate_expenses.pluck(:id)
    if duplicate_expense_ids.present?
      duplicate_expenses = ManualExpense.merchant_like(expense.manual_expense.merchant_name, duplicate_expense_ids)
    end
  end

end