# this operation returns the list of bank accounts for a particular account owner
class BankTransfer::AccountOwners::BankAccounts < BankTransfer::AccountOwners::Base

  attr_accessor :bank_accounts, :account_owner

  class BankTransfer::AccountOwners::BankAccounts::BankAccountsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts

    def init
      self.bank_accounts = params[:bank_accounts]
    end

  end

  def init
    super()
    id = params[:account_owner_id] || params[:id]
    case params[:account_owner_type]
      when "YesBankVendor"
        self.account_owner = self.company.yes_bank_vendors.find_by(id: id)
      when "User"
        self.account_owner = self.company.users.find_by(id: id)
      else
        # default case, shall be YesBankVendor
        self.account_owner = self.company.yes_bank_vendors.find_by(id: id)
    end
  end

  def validate
    if self.account_owner.blank?
      add_message :error, "Account owner not found"
    end
  end

  def process
    self.bank_accounts = self.account_owner.bank_accounts
  end

  def success
    params[:bank_accounts] = self.bank_accounts
    BankTransfer::AccountOwners::BankAccounts::BankAccountsPresenter.new(user, params, messages)
  end

end