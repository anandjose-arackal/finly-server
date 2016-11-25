
class EmployeeStatement::Export::Base < EmployeeStatement::Base

  attr_accessor :result

  class EmployeeStatement::Export::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header

    def init
      self.data = params[:data]
      self.header = params[:header]
    end

  end


  def init
    super()
  end

  def validate
    if end_date.to_date > DateUtils.local_date
      messages[:error] << "End date cannot be in the future"
      return
    end
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
    expense = transaction.expense rescue nil
    unless expense
      return "N/A"
    end
    expense.category.name
  end

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

end