class CompaniesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def notify
    # todo
    @result = Company::VirtualAccount::Balance.(current_user, params)
    if @result.success?
      @company_balance = @result.balance
    else
      @company_balance = 0
    end
    render partial: 'notify'
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end
end
