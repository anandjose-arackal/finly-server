class BankTransfer::ItzCash::Reimbursement::Beneficiary::SetDefault < BankTransfer::ItzCash::Reimbursement::Base
  attr_accessor :account, :current_default_account

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless user&.itz_cash_dmt_sender

      return
    end
    unless params&.dig(:id)
      add_message :error, 'Reimbursement Account not to be set as default'
    end
  end

  def init
    self.current_default_account = user.itz_cash_dmt_sender.beneficiaries.reimbursement_accounts.default
    self.account = user.itz_cash_dmt_sender.beneficiaries.reimbursement_accounts.with_id(params[:id])&.first
  end

  def validate
    unless account.present?
      add_message :error, 'Account not found'
    end
  end

  def process
    self.account.update(default: true)
    current_default_account&.each do |acc|
      next if acc.blank? or acc == self.account
      acc.update(default: false)
    end
  end

end