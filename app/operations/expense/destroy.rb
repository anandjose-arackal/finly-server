# action to destroy a particular expense.
# params:
# expense_id, or id : id of the expense that is to be deleted.

class Expense::Destroy < Expense::Base
  attr_accessor :expenses

  def pre_validate
    if params.blank? or user.blank?
      add_message :error, 'Parameters or user not present'
    end
    if params[:expense_id].blank? and params[:id].blank?
      add_message :error, 'Expense not found'
    end
  end

  def init
    self.expenses = user.expenses.with_id(params[:expense_id] || params[:id])
  end

  def authorize
    non_owner_expenses = self.expenses&.pluck(:user_id) - [user.id]
    if non_owner_expenses.present?
      add_message :error, 'Only expense owners can delete expenses'
      raise_unauthorized_exception
    end
  end

  def validate
    unless expenses.present?
      add_message :error, 'Cannot find expense to delete'
      return
    end

    self.expenses.each do |expense|
      if expense.expense_type_id == ExpenseType.card_expense_id
        add_message :error, 'Card expenses cannot be deleted'
      end

      if expense.report.present?
        unless expense.report.editable?
          add_message :error, 'Report is not editable at this stage to delete the selected expense'
          return
        end
      end
    end
  end

  def process
    self.expenses.each do |expense|
      unless expense.destroy
        add_message :error, expense.errors.full_messages
        return false
      end
    end
  end

  def post_process
    # mail?
    add_message :success, 'Expense deleted'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end
