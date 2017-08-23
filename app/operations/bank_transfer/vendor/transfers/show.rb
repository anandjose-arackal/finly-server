# This operation will fetch all the

class BankTransfer::Vendor::Transfers::Show < BankTransfer::Vendor::Base

  attr_accessor :vendor, :receiving_transactions, :bank_accounts

  def init
    super()
    id = params[:id] || params[:vendor_id]
    self.vendor = company.yes_bank_vendors.find_by(id: id)
  end

  def process
    self.bank_accounts = vendor.bank_accounts
    self.receiving_transactions = Payment.with_receiving_account_type("YesBankVendor").with_receiving_account_id(bank_accounts.pluck(:id))
  end

  def success
    params[:receiving_transactions] = receiving_transactions
    params[:bank_accounts] = bank_accounts
  end

  class BankTransfer::Vendor::Transfers::Show::VendorPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receiving_transactions

    def init
      self.receiving_transactions = params[:receiving_transactions]
      self.bank_accounts = params[:bank_accounts]
    end

  end

end
