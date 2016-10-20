class CompaniesController < ApplicationController

  def add_balance
    @result = Company::AddBalance.(user, params)
    respond
  end
end
