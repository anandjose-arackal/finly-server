# updating the expense from user's expenses view.
# The only editable fields are: editable_merchant, note, category_id, and receipts

class Expense::Card::Update < Expense::Card::Base
  attr_accessor :updated_expense_params

  def pre_validate
    super
    if params.blank?
      errors << "Parameters not present."
    end
    if params[:expense_id].blank? or params[:id].blank?
      errors << "Expense ID missing!"
    end
  end


  def init
    super
    # setting up the expense params for updation
    self.updated_expense_params = update_card_expense_params
    if expense.card_expense.present? and params[:expense][:merchant]
      self.updated_expense_params[:card_expense_attributes][:id] = expense.card_expense.id
    end
    if expense.receipts.present? and params[:expense][:receipt]
      self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
    end
  end


  def validate
    unless expense
      errors << "Cannot find expense to edit. "
    end
  end


  def authorize
    unless expense.user_id == user.id
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

  private
  # this will be called when the merchant, or receipt of the expense needs to be updated, from the user's view of expenses
  def update_card_expense_params
    params.require(:expense).permit(:note, :category_id,
                                    card_expense_attributes: [:editable_merchant, :id],
                                    receipts_attributes: [:image, :user_id, :id])
  end

end
