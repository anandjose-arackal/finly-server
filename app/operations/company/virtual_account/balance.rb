class Company::VirtualAccount::Balance < BaseOperation
  attr_accessor :total_wallet_balance, :balance

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
    # todo hit api to calculate balance here

    itzcash_balance = 20000
    self.balance = (itzcash_balance - total_wallet_balance)
  end

  def success
    Company::VirtualAccount::Balance::SuccessPresenter.new(user, {balance: self.balance}, messages)
  end

  class Company::VirtualAccount::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :balance

    def init
      self.balance = params[:balance]
    end

  end

end