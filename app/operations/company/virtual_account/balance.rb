class Company::VirtualAccount::Balance < BaseOperation
  attr_accessor :total_wallet_balance, :balance, :account_number

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.total_wallet_balance = user.company.account.wallet_balance.value
  end

  def process
    response = ItzCash::VirtualAccountBalance.(user.company)
    unless response.success?
      add_message :error, response.messages[:error]
      return
    end

    itzcash_balance = response.wallets.first[:balance]
    self.account_number = response.wallets.first[:account_number]
    self.balance = (itzcash_balance - total_wallet_balance)

    if response.company.itz_cash_property.easy_account_no.blank? or response.company.itz_cash_property.easy_account_no.blank?
      company.itz_cash_property.update_attribute(:easy_account_no, response.wallets.first[:account_number])
    end
  end

  def success
    Company::VirtualAccount::Balance::SuccessPresenter.new(user, {balance: self.balance, account_number: self.account_number}, messages)
  end

  class Company::VirtualAccount::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :balance, :account_number

    def init
      self.balance = params[:balance]
      self.account_number = params[:account_number]
    end

  end

end