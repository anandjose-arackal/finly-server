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
    op = BankTransfer::BankAccounts::Index.(user, params)
    if op.success?
      self.bank_accounts_count = op.bank_accounts.count
    end
  end

  def success
    bank_accounts_count
  end

end