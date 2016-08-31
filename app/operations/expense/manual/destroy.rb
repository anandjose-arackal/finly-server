class Expense::Manual::Destroy < Expense::Base

  def pre_validate
    if params.blank? or user.blank?
      errors << "Parameters or user not present."
    end
    if params[:expense_id].nil?
      errors << "Expense ID missing!"
    end
  end

  def init
    self.expense = user.expenses.find_by_id(params[:expense_id])
  end

  def authorize
    unless expense.id == user.id
      errors << "You do not own this expense."
    end
  end

  def validate
    unless expense
      errors << "Cannot find expense to destroy"
    end
  end

  def process
    unless expense.destroy
      errors << expense.errors.full_messages
      return false
    end
    success
  end

  def post_process
    # mail?
  end


  # since it's a destroy method, it return true or false based on success of the operation.
  def retrieve
    if is_success?
      return true
    else
      return false
    end
  end

end