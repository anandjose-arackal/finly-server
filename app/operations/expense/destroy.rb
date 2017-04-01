# action to destroy a particular expense.
# params:
# expense_id, or id : id of the expense that is to be deleted.

class Expense::Destroy < Expense::Base

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << 'Parameters or user not present'
    end
    if params[:expense_id].nil? and params[:id].nil?
      messages[:error] << 'Expense ID missing!'
    end
  end

  def init
    self.expense = user.expenses.find_by_id(params[:expense_id] || params[:id])
  end

  def authorize
    unless expense
      messages[:error] << 'Cannot find expense to delete'
      raise_unauthorized_exception
    end

    unless expense.user_id == user.id
      messages[:error] << 'You do not own this expense'
      raise_unauthorized_exception
    end
  end

  def validate
    if expense.expense_type_id == ExpenseType.card_expense_id
      messages[:error] << "Card expenses cannot be deleted."
    end

    if expense.report.present?
      unless report.editable?
        add_message :error, "Report is not editable at this stage"
      end
    end
  end

  def process
    unless expense.destroy
      messages[:error] = expense.errors.full_messages
      return false
    end
    return true
  end

  def post_process
    # mail?
    messages[:success] << 'Expense deleted'
  end

end
