# updating the expense from user's expenses view.
# The only editable fields are: editable_merchant, note, category_id, and receipts

class Expense::Card::Update < Expense::Card::Base

  attr_accessor :old_expense, :updated_expense_params

  def pre_validate
    if params.blank? or user.blank?
      errors << "Parameters or user not present."
    end
    if params[:expense_id].nil?
      errors << "Expense ID missing!"
    end
  end


  def init
    self.expense = self.old_expense = user.expenses.find_by_id(params[:expense_id])
    # setting up the expense params for updation
    self.updated_expense_params = update_card_expense_params
    if expense.card_expense.present?
      self.updated_expense_params[:card_expense_attributes][:id] = expense.card_expense.id
    end
    if expense.receipts.present?
      self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
    end
  end


  def validate
    unless expense
      errors << "Cannot find expense to edit. "
    end
  end


  def authorize
    unless expense.id == user.id
      errors << "You do not own this expense."
    end
  end


  def process
    unless expense.update(updated_expense_params)
      errors << self.expense.errors.full_messages
      return false
    end
    success
  end

  def post_process
    # send mailer or notification indicating updation of expense
  end
end
