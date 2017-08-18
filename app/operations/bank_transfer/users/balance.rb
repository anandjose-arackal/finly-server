class BankTransfer::Users::Balance < BankTransfer::Users::Base

  attr_accessor :role_id, :company_balance, :wallet_balance

  def authorized_user_types
    [:company_admin, :finance]
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? && params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end


  def process
    case role_id
      when UserRole.id_for(:admin) && user.company_admin?
        self.company_balance = AccountManager::Balance::Check.(user.company.yes_bank_company_account, params).balance
        self.wallet_balance = AccountManager::Balance::Check.(user.bank_wallet, params).balance
      else
        self.wallet_balance = AccountManager::Balance::Check.(user.bank_wallet, params).balance
    end
  end

  def success
    params[:company_balance] = company_balance
    params[:wallet_balance] = wallet_balance
    BankTransfer::Users::Balance::BalancePresenter.new(user, params, messages)
  end

  class BankTransfer::Users::Balance::BalancePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :company_balance, :wallet_balance

    def init
      self.company_balance = params[:company_balance]
      self.wallet_balance = params[:wallet_balance]
    end
  end
end