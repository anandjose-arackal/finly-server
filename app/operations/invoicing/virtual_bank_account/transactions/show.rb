class Invoicing::VirtualBankAccount::Transactions::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :transactions, :virtual_bank_account

  class Invoicing::VirtualBankAccount::Transactions::Show::TransactionsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transactions

    def init
      self.transactions = params[:transactions]
    end
  end


  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = user.company.virtual_bank_accounts.find_by(id: id)
  end

  def process
    self.transactions = Payment.with_initiating_account_id(self.virtual_bank_account.id)
  end

  def success
    params[:transactions] = self.transactions
    Invoicing::VirtualBankAccount::Transactions::Show::TransactionsPresenter.new(user, params, messages)
  end
end