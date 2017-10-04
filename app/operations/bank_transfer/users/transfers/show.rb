# this operation will show all transfers done to any of this particular user's accounts

class BankTransfer::Users::Transfers::Show < BankTransfer::Users::Base

  attr_accessor :employee, :receiving_transactions, :bank_accounts

  def init
    super()
    id = params[:id] || params[:user_id]
    self.employee = company.users.find_by(id: id)
  end

  def process
    self.bank_accounts = employee.bank_accounts
    self.receiving_transactions = employee.receiving_payments.with_receiving_account_type("BankAccount")
  end

  def success
    params[:receiving_transactions] = receiving_transactions
    params[:bank_accounts] = bank_accounts
    params[:employee] = self.employee
    BankTransfer::Users::Transfers::Show::AccountOwnersPresenter.new(user, params)
  end

  class BankTransfer::Users::Transfers::Show::AccountOwnersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receiving_transactions, :bank_accounts, :employee

    def init
      self.receiving_transactions = params[:receiving_transactions]
      self.bank_accounts = params[:bank_accounts]
      self.employee = params[:employee]
    end

  end

end