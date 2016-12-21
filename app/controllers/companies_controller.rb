class CompaniesController < ApplicationController

  def notify
    # todo
    @company_balance = 30000.00
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end

end
