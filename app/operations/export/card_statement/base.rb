class Export::CardStatement::Base < Export::Base

  attr_accessor :result, :start_date, :end_date, :selected_user

  class Export::CardStatement::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header

    def init
      self.data = params[:data]
      self.header = params[:header]
    end

  end

  def headers
    ["Date", "Transaction Type", "Merchant", "Debit Amount", "Credit Amount", "Category", "Status"]
  end


  def init
    load_selected_user
    if params[:filter_date_from]
      self.start_date = DateTime.parse(params[:filter_date_from])
    else
      self.start_date = DateTime.parse("01-01-1990") # arbitrarily chosen as the lower bound date
    end
    if params[:filter_date_to]
      self.end_date = DateTime.parse(params[:filter_date_to] + " 23:59:59")
    else
      self.end_date = DateUtils.local_date_time
    end
  end

  def validate

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

  def retrieve_merchant_name(transaction)
    if transaction.transaction_type == "Debit"
      return transaction.merchant_name
    else
      return "N/A"
    end
  end

  def transaction_category(transaction)
    expense = transaction.card_expense.expense rescue nil
    unless expense
      return "N/A"
    end
    expense.category.name
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

  private

  def load_selected_user
    if personal_view?
      self.selected_user = self.user
      return
    end
    user_op = User::Team::Index.new(user, params)
    user_result = user_op.run
    unless user_op.success?
      self.messages[:error] = user_op.messages[:error]
      return
    end
    user_id = (params[:id] or params[:user_id])
    self.selected_user = user_result.with_id(user_id).first rescue nil
    if self.selected_user.blank?
      messages[:error] << 'User not found'
    end
  end

end
