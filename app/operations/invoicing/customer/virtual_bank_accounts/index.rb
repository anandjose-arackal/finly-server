class Invoicing::Customer::VirtualBankAccounts::Index < Invoicing::Customer::Base

  attr_accessor :virtual_accounts, :customer

  def init
    customer_id = params[:customer_id]
    self.customer = user.company.customers.find_by(id: customer_id)
  end

  def validate
    if self.customer.blank?
      add_message :error, "Customer not found"
    end
  end

  def process
    self.virtual_accounts = self.customer.virtual_bank_accounts
  end

  def success
    params[:virtual_accounts] = self.virtual_accounts
    Invoicing::Customer::VirtualBankAccounts::Index::VirtualBankAccountsPresenter.new(user, params, messages)
  end

  class Invoicing::Customer::VirtualBankAccounts::Index::VirtualBankAccountsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_accounts

    def init
      self.virtual_accounts = params[:virtual_accounts]
    end
  end
end