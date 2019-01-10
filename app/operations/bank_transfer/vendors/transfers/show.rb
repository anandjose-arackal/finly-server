# This operation will fetch all the

class BankTransfer::Vendors::Transfers::Show < BankTransfer::Vendors::Base

  attr_accessor :vendor, :receiving_transactions, :bank_accounts

  def init
    super()
    id = params[:id] || params[:vendor_id]
    self.vendor = company.yes_bank_vendors.non_deleted.find_by(id: id)
  end

  def process
    self.bank_accounts = vendor.bank_accounts
    self.receiving_transactions = vendor.receiving_payments.successful_and_failed_only
  end

  def success
    params[:receiving_transactions] = receiving_transactions
    params[:bank_accounts] = bank_accounts
    params[:vendor] = vendor
    BankTransfer::Vendors::Transfers::Show::AccountOwnersPresenter.new(user, params)
  end

  class BankTransfer::Vendors::Transfers::Show::AccountOwnersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receiving_transactions, :bank_accounts, :vendor

    def init
      self.receiving_transactions = params[:receiving_transactions]
      self.bank_accounts = params[:bank_accounts]
      self.vendor = params[:vendor]
    end

  end
end
