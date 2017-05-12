# this will take expense id of the card expense that needs to be cancelled along with the
# associated transaction that needs to be marked against it and mark the expense as cancelled
# if params[:unmark] is set as true, unmark the expense as cancellation

class Expense::ExCard::MarkAsCancelled < Expense::ExCard::Base

  attr_accessor :selected_expense, :cancelled_transaction, :selected_card_expense

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:expense_id]
    # because the expense will always belong to a particular user
    self.selected_expense = user.expenses.find_by(id: id)
    self.cancelled_transaction = user.card_transactions.find_by(id: params[:transaction_id])
  end

  def validate
    # check if the expense is cancellable
    unless selected_expense.cancellable?
      add_message :error, "This expense cannot be cancelled"
      return
    end

    # check if the transaction that is being marked as cancelled is a refund at all
    unless cancelled_transaction.refund?
      add_message :error, "This transaction is not a refund"
      return
    end

    if cancelled_transaction.cancelled
      add_message :error, "This transaction has already been marked as cancelled"
    end
  end

  def authorize
    unless selected_expense
      raise_unauthorized_exception
    end
  end

  def process
    if params[:unmark] == '1' || params[:unmark] == true
      if selected_expense.card_expense.update(cancelled: false)
        self.cancelled_transaction = selected_expense.card_expense.cancelled_transaction
        self.cancelled_transaction.update(cancelled: false)
        self.selected_expense.update(cancelled_against_transaction: nil)
      else
        add_message :error, selected_expense.card_expense.errors.full_messages
      end
    else
      if selected_expense.card_expense.update(cancelled: true, cancelled_against_transaction: self.cancelled_transaction)
        self.cancelled_transaction.update(cancelled: true)
      else
        add_message :error, selected_expense.card_expense.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, "Expense marked as cancelled"

    # mailer maybe?
  end

  def success
    params[:expense] = selected_expense
    Expense::ExCard::Base::CardExpensePresenter.new(user, params, messages)
  end

end