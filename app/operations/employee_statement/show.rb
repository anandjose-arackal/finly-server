class EmployeeStatement::Show < EmployeeStatement::Base

  attr_accessor :items, :transactions

  def init
    super()
    self.transactions = selected_user.card_transactions.with_transaction_timestamp_range(start_date.beginning_of_day, end_date.end_of_day)
    self.items = []
  end

  def authorize
    unless selected_user
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    transactions.each do |transaction|
      self.items << {
          date: Time.parse(transaction.transaction_timestamp.to_s).strftime('%d/%m/%y: %H:%M:%S'),
          transaction_type: retrieve_transaction_type(transaction),
          merchant: retrieve_merchant_name(transaction),
          debit_amount: (transaction.transaction_type == 'Debit') ? "#{transaction.billing_amount.currency.symbol} " + transaction.billing_amount_value.to_s : '- -' ,
          credit_amount: (transaction.transaction_type == 'Credit') ? "#{transaction.billing_amount.currency.symbol} " + transaction.billing_amount_value.to_s : '- -' ,
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

  def retrieve_merchant_name(transaction)
    trans_mode = transaction.transaction_mode.upcase rescue nil
    if transaction.transaction_type == "Debit"
      if ["POS", "ECOM"].include?(trans_mode)
        return transaction.merchant_name
      else
        return "N/A"
      end
    else
      return "N/A"
    end
  end

  def transaction_status(transaction)
    expense = transaction.card_expense.expense rescue nil
    unless expense
      return "N/A"
    end
    if expense.expense_status_id == ExpenseStatus.unreported_id or expense.expense_status_id == ExpenseStatus.unsubmitted_id
      return "Unverified"
    elsif expense.expense_status_id == ExpenseStatus.submitted_id
      if expense.report.approved? or expense.report.closed? or expense.report.settled? or expense.report.settlement_confirmed?
        return "Verified"
      else
        return "Unverified"
      end
    end
  end

  def transaction_category(transaction)
    expense = transaction.card_expense.expense rescue nil
    unless expense
      return "N/A"
    end
    expense.category.name
  end

  def retrieve_transaction_type(transaction)
    trans_mode = transaction.transaction_mode.upcase rescue nil
    if transaction.transaction_type == "Credit"
      return "Load"
    elsif transaction.transaction_type == "Debit"
      if trans_mode == "POS"
        return "POS Transaction"
      elsif trans_mode == "ATM"
        return "ATM Withdrawal"
      elsif trans_mode == 'ECOM'
        return "Online Transaction"
      else
        return "Withdrawal"
      end
    end
  end

end
