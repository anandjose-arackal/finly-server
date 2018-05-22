class BankTransfer::Vendors::Transfers::BankAccounts < BankTransfer::Vendors::Base

  attr_accessor :bank_accounts, :vendor

  class BankTransfer::Vendors::Transfers::BankAccounts < BaseOperation::BasePresenter::SuccessPresenter

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


end