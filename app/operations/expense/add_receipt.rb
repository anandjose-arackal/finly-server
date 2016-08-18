class Expense::AddReceipt < Expense::Base

  attr_accessor :receipt

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
      return
    end
    # if the expense already has an associated receipt, that will be unassociated and
    # moved to the receipts screen.
    if expense.receipts.present?
      receipt = expense.receipts.first
      receipt.update_attributes(parent_id: nil, parent_type: nil)
    end
  end


  def authorize
    unless expense.user_id == user.id
      errors << "You do not own this expense."
    end
  end


  def process
    self.receipt = user.receipts.build(receipt_params)
    receipt.parent = expense
    unless receipt.save
      errors << "DB Error. Try again."
    end
  end


  def retrieve
    if is_success?
      return receipt
    else
      return false
    end
  end
end