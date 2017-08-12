# this operation takes a bunch of account ids and returns the bank details of all those
# accounts from the database
# params: {
#   account_owner_type: 1 for User, 2 for YesBankVendor
#   array of bank account ids
# }

class BankTransfer::YesBank::AccountDetails < BankTransfer::YesBank::Base

  attr_accessor :bank_accounts, :account_ids

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.account_ids = params[:account_ids]
  end

  def process
    self.bank_accounts = user.company.bank_accounts.with_owner_ids(params[:account_owner_type], account_ids)
  end

  def success
    params[:bank_accounts] = bank_accounts
    BankTransfer::YesBank::AccountDetails::AccountsPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::AccountDetails::AccountsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts

    def init
      self.bank_accounts = params[:bank_accounts]
    end
  end

end