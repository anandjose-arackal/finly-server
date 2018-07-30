class BankTransfer::Vendors::BankAccounts < BankTransfer::Vendors::Base

  attr_accessor :bank_accounts, :vendor

  class BankTransfer::Vendors::BankAccounts::BankAccountsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts

    def init
      self.bank_accounts = params[:bank_accounts]
    end
  end

  def init
    id = params[:id] || params[:vendor_id]
    self.vendor = user.company.yes_bank_vendors.find_by(id: id)
    self.bank_accounts = self.vendor&.bank_accounts
  end

  def validate
    if self.vendor.blank?
      add_message :error, "No vendor found"
      return
    end
  end

  def success
    params[:bank_accounts] = self.bank_accounts
    BankTransfer::Vendors::BankAccounts::BankAccountsPresenter.new(user, params, messages)
  end

end
