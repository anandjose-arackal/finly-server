class Expense::Cancelled::CancelledTransactions < Expense::Base

  attr_accessor :cancelled_transactions, :selected_expense

  class Expense::Cancelled::CancelledTransactions::TransactionPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :cancelled_transactions

    def init
      self.cancelled_transactions = params[:cancelled_transactions]
    end

  end


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:expense_id]
    self.selected_expense = user.expenses.find_by(id: id)
  end

  def validate
    unless selected_expense.card_expense?
      add_message :error, "Only card expenses can have cancelled transactions"
      return
    end
  end

  def authorize
    unless selected_expense
      raise_unauthorized_exception
    end
  end

  def process
    self.cancelled_transactions = selected_expense.card_expense.cancelled_against_transactions
  end

  def success
    params[:cancelled_transactions] = cancelled_transactions
    Expense::Cancelled::CancelledTransactions::TransactionPresenter.new(user, params, messages)
  end
end