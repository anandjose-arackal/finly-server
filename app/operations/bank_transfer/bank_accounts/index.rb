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
    case role_id
      when UserRole.id_for(:admin)
        self.bank_accounts = company.bank_accounts
      when UserRole.id_for(:manager)
        # for now only show vendor bank accounts - will later have team details
      when UserRole.id_for(:finance_manager)
        # for now only show vendor accounts - will later have team details
      else
        account_ids = company.bank_accounts.only_vendors.pluck(:id)
        account_ids += company.bank_accounts.only_users.with_owner_id(user.id).pluck(:id)
        self.bank_accounts = BankAccount.with_id(account_ids)
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
    end
  end
end