class CompaniesController < ApplicationController


  before_action -> { doorkeeper_authorize! :web}

  def notify
    # todo
    @result = Company::VirtualAccount::Balance.(current_user, params)
    if @result.success?
      @company_balance = @result.balance
      @company = @result.company
    else
      @company_balance = 0
      @company = nil
    end
    respond
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end
end
