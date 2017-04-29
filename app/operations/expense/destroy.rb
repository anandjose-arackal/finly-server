# action to destroy a particular expense.
# params:
# expense_id, or id : id of the expense that is to be deleted.

class Expense::Destroy < Expense::Base

  def pre_validate
    if params.blank? or user.blank?
      add_message :error, 'Parameters or user not present'
    end
    if params[:expense_id].nil? and params[:id].nil?
      add_message :error, 'Expense ID missing!'
    end
  end

  def init
    self.expense = user.expenses.find_by_id(params[:expense_id] || params[:id])
  end

  def authorize
    unless expense
      add_message :error, 'Cannot find expense to delete'
      raise_unauthorized_exception
    end

    unless expense.user_id == user.id
      add_message :error, 'You do not own this expense'
      raise_unauthorized_exception
    end
  end

  def validate
    if expense.expense_type_id == ExpenseType.card_expense_id
      add_message :error, 'Card expenses cannot be deleted'
    end

    if expense.report.present?
      unless expense.report.editable?
        add_message :error, "Report is not editable at this stage"
      end
    end
  end

  def process
    if expense.report.present?
      unless expense.update(report_id: nil)
        add_message :error, expense.errors.full_messages
        return false
      end
    else
      unless expense.destroy
        messages[:error] = expense.errors.full_messages
        return false
      end
    end
  end

  def post_process
    # mail?
    messages[:success] << 'Expense deleted'
  end

end
