class BankTransfer::BankAccounts::Index < BankTransfer::BankAccounts::Base

  attr_accessor :user_ids, :vendor_ids, :company, :bank_accounts

  def init
    self.company = user.company
    self.user_ids = company.users.pluck(:id)
    self.vendor_ids = company.yes_bank_vendors.pluck(:id)
  end

  def process
    # extracting the bank accounts owned by users and vendors
    self.bank_accounts = company.bank_accounts
  end

  def success
    params[:bank_accounts] = bank_accounts
    BankTransfer::BankAccounts::Index::IndexPresenter.new(user, params, messages)
  end

  class BankTransfer::BankAccounts::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts

    has_scope :filter_owner_type

    def init
      self.bank_accounts = params[:bank_accounts]
      self.bank_accounts = apply_scopes(bank_accounts, params)
    end
  end
end