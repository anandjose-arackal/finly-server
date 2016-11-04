class CompaniesController < ApplicationController

  def notify
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end
end
