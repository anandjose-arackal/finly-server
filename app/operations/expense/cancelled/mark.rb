# this will take expense id of the card expense that needs to be cancelled along with the
# associated transaction that needs to be marked against it and mark the expense as cancelled
# if params[:unmark] is set as true, unmark the expense as cancellation

class Expense::Cancelled::Mark < Expense::Base

  attr_accessor :selected_expense, :cancelled_transactions, :selected_card_expense

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:expense_id]
    # because the expense will always belong to a particular user
    self.selected_expense = user.expenses.only_card_expenses.find_by(id: id)
    transactions_ids = params[:transaction_id] # can be an array or integer
    self.cancelled_transactions = user.card_transactions.where(id: transactions_ids)
  end

  def validate
    unless selected_expense
      add_message :error, "Expense not found"
      return
    end

    unless selected_expense.card_expense?
      add_message :error, "Only card expenses can be cancelled"
    end

    # check if the expense is cancellable
    unless selected_expense.cancellable?
      add_message :error, "This expense cannot be cancelled"
      return
    end

    # check if the transaction that is being marked as cancelled is a refund at all
    # also check if the respective transactions are already cancelled by any chance
    cancelled_transactions.each do |transaction|
      unless transaction.refund?
        add_message :error, "This transaction is not a refund"
        return
      end
      if transaction.cancelled
        add_message :error, "One of these transactions has already been marked as cancelled"
      end
    end
  end

  def authorize

  end

  def process
    if selected_expense.card_expense.update(cancelled: true)
      cancelled_transactions.update_all(cancelled_against_expense_id: selected_expense.card_expense.id, cancelled: true)
    else
      add_message :error, selected_expense.card_expense.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Expense marked as cancelled"

    # mailer maybe?
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end