class BankTransfer::BankAccounts::Count < BankTransfer::BankAccounts::Base
  attr_accessor :company, :bank_accounts_count, :role_id

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
        self.bank_accounts_count = company.bank_accounts.count
      when UserRole.id_for(:manager)
        # for now only show vendor bank accounts - will later have team details
      when UserRole.id_for(:finance_manager)
        # for now only show vendor accounts - will later have team details
      else
        account_ids = company.bank_accounts.only_vendors.pluck(:id)
        account_ids += company.bank_accounts.only_users.with_owner_id(user.id).pluck(:id)
        self.bank_accounts_count = account_ids.size
    end
  end

  def success
    bank_accounts_count
  end

end