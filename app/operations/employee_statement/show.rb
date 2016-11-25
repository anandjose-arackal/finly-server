class EmployeeStatement::Show < EmployeeStatement::Base

  attr_accessor :items, :transactions

  def init
    super()
    self.transactions = selected_user.card_transactions.where('transaction_timestamp > ? AND transaction_timestamp <= ?', start_date, end_date)
    self.items = []
  end

  def authorize
    unless selected_user
      raise_unauthorized_exception
    end
  end

  def validate
    if end_date > DateUtils.local_date
      messages[:error] << "End Date cannot be in the future"
    end
  end

  def process
    transactions.each do |transaction|
      self.items << {
          date: transaction.transaction_timestamp,
          transaction_type: retrieve_transaction_type(transaction),
          merchant: transaction.merchant_name,
          debit_amount: (transaction.transaction_type == "Debit") ? transaction.billing_amount_value : "N/A" ,
          credit_amount: (transaction.transaction_type == "Credit") ? transaction.billing_amount_value : "N/A" ,
          # balance: (0), # todo need to be decided
          category: transaction_category(transaction),
          status: transaction_status(transaction)
      }
    end
  end

  def success
    EmployeeStatement::Base::StatementPresenter.new(user, {items: items}, messages)
  end

  private

  def transaction_status(transaction)
    expense = transaction.expense rescue nil
    unless expense
      return "N/A"
    end
    if expense.expense_status_id == ExpenseStatus.unreported_id or expense.expense_status_id == ExpenseStatus.unsubmitted_id
      return "Unverified"
    elsif expense.expense_status_id == ExpenseStatus.submitted_id
      if expense.report.approved? or expense.report.closed? or expense.report.reimbursed? or report.reimbursement_confirmed?
        return "Verified"
      else
        return "Unverified"
      end
    end
  end

  def transaction_category(transaction)
    expense = transaction.expense rescue nil
    unless expense
      return "N/A"
    end
    expense.category.name
  end

  def retrieve_transaction_type(transaction)
    if transaction.transaction_type == "Credit"
      return "Load"
    elsif transaction.transaction_type == "Debit"
      if transaction.transaction_mode == "POS"
        return "POS Transaction"
      elsif transaction.transaction_mode == "ATM"
        return "ATM Withdrawal"
      else
        return "Online Transaction"
      end
    end
  end

end