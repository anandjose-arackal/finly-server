class Expense::AddReceipt < Expense::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if params.blank? or user.blank?
      errors << "No user or params passed."
    end
  end

  def init
    self.expense = user.expenses.find_by_id(params[:expense_id])
  end

  def validate
    unless expense
      errors << "Expense not found."
    end
  end

  def authorize
    unless expense.user_id == user.id
      errors << "You do not own this expense."
    end
  end

  def process

  end
end