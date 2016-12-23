class CompaniesController < ApplicationController

  before_action :authenticate_user!
  before_action :superadmin_accounts

  def notify
    # todo
    @result = Company::VirtualAccount::Balance.(current_user, params)
    if @result.success?
      @company_balance = @result.balance
    else
      @company_balance = 0
    end
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end

  private

  def superadmin_accounts
    unless Constants::SUPERADMIN_ACCOUNTS.include?(current_user.email)
      redirect_to root_url
    end
  end

end
