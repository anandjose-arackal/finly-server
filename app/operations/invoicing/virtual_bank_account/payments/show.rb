class Invoicing::VirtualBankAccount::Payments::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :payments, :virtual_bank_account

  class Invoicing::VirtualBankAccount::Transactions::Show::TransactionsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments

    def init
      self.payments = [1,2,3,6,5,6,5,6]
    end
  end


  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = user.company.virtual_bank_accounts.find_by(id: id)
  end

  def process
    self.payments = Payment.with_initiating_account_id(self.virtual_bank_account.id)
  end

  def success
    params[:payments] = self.payments
    Invoicing::VirtualBankAccount::Payments::Show::TransactionsPresenter.new(user, params, messages)
  end

end