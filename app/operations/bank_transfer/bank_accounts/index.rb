class BankTransfer::BankAccounts::Index < BankTransfer::BankAccounts::Base

  attr_accessor :company, :bank_accounts, :role_id

  def init
    self.company = user.company
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def process
    if user.vendor_payments_initiator? || user.vendor_payments_admin?
      self.bank_accounts = company.bank_accounts.non_deleted
    else
      account_ids = company.bank_accounts.only_vendors.pluck(:id)
      account_ids += company.bank_accounts.only_users.with_owner_id(user.id).pluck(:id)
      self.bank_accounts = BankAccount.with_id(account_ids).non_deleted
    end
  end

  def success
    params[:bank_accounts] = bank_accounts
    BankTransfer::BankAccounts::Index::IndexPresenter.new(user, params, messages)
  end

  class BankTransfer::BankAccounts::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts

    has_scope :beneficiary_type
    has_scope :filter_search

    def init
      self.bank_accounts = params[:bank_accounts]
      self.bank_accounts = apply_scopes(bank_accounts, params)
      self.bank_accounts = bank_accounts.paginate(page: params[:page], per_page: params[:per_page])
    end
  end
end