class  Invoicing::Transactions::Index < Invoicing::Transactions::Base
  attr_accessor :transactions, :virtual_bank_accounts

  def init
    virtual_account_op = Invoicing::VirtualBankAccount::Index.(user, params)

    self.virtual_bank_accounts = virtual_account_op.virtual_bank_accounts
  end

  def process
    self.transactions = Payment.with_initiating_account(self.virtual_bank_accounts)
  end

  def success
    params[:transactions] = self.transactions
    Invoicing::Transactions::Index::IndexPresenter.new(user, params, messages)
  end

  class Invoicing::Transactions::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :transactions

    def init
      self.transactions = params[:transactions]
    end
  end
end