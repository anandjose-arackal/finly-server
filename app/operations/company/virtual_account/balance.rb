class Company::VirtualAccount::Balance < BaseOperation
  attr_accessor :total_wallet_balance, :balance, :account_number, :scheduled_payment_orders_balance, :company

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init

    # self.company = user.company || 
    self.company = params[:company] || user.company

    self.total_wallet_balance = company.account.wallet_balance.value
    self.scheduled_payment_orders_balance = company.payment_orders.scheduled.total_amount_requested
  end

  def process
    response = ItzCash::VirtualAccountBalance.(company)
    unless response.success?
      add_message :error, response.messages[:error]
      return
    end

    itzcash_balance = response.wallets.first[:balance]
    self.account_number = response.wallets.first[:account_number]
    self.balance = (itzcash_balance - total_wallet_balance - scheduled_payment_orders_balance)
    self.company = response.company

    if response.company.itz_cash_property.easy_account_no.blank? or response.company.itz_cash_property.easy_account_no.blank?
      response.company.itz_cash_property.update_attribute(:easy_account_no, response.wallets.first[:account_number])
    end
  end

  def success
    Company::VirtualAccount::Balance::SuccessPresenter.new(user, {balance: self.balance, account_number: self.account_number, company: self.company}, messages)
  end

  class Company::VirtualAccount::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :balance, :account_number, :company

    def init
      self.balance = params[:balance]
      self.account_number = params[:account_number]
      self.company = params[:company]
    end

  end

end