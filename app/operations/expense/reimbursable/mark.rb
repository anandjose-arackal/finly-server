class Expense::Reimbursable::Mark < Expense::Reimbursable::Unmark

  attr_accessor :selected_expense

  def validate
    unless selected_expense.unreported?
      add_message :error, "This expense cannot be edited at this stage"
      return
    end
    if selected_expense.card_expense?
      add_message :error, "Card expenses are non-reimbursable by default"
      return
    end
    if selected_expense.reimbursable
      add_message :error, "This expense is already marked as reimbursable"
    end
  end

  def process
    unless selected_expense.update(reimbursable: true)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Expense marked as reimbursable"
  end
end