# action to destroy a particular expense.
# params:
# expense_id, or id : id of the expense that is to be deleted.

class Expense::Manual::Destroy < Expense::Base

  def pre_validate
    if params.blank? or user.blank?
      errors << "Parameters or user not present."
    end
    if params[:expense_id].nil? and params[:id].nil?
      errors << "Expense ID missing!"
    end
  end

  def init
    self.expense = user.expenses.find_by_id(params[:expense_id] || params[:id])
  end

  def authorize
    unless expense
      errors << "Cannot find expense to destroy"
      raise_unauthorized_exception
    end

    unless expense.user_id == user.id
      errors << "You do not own this expense."
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    unless expense.destroy
      errors << expense.errors.full_messages
      return false
    end
    return true
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