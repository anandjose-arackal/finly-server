class Superadmin::CompaniesController < ApplicationController

  before_action :authenticate_user!

  def new

  end

  def show
    @result = Company::Show.(current_user, params)
  end

  def create
    @result = Company::Create.(current_user, params)
    # temporary rendering for html testing.
    if @result.success?
      flash[:success] = 'Company created'
    else
      flash[:error] = @result.messages[:error]
    end
    redirect_to superadmin_companies_path
  end

  def add_admin
    @result = Company::AddAdmin.(current_user, params)
    # temporary rendering for html testing.
    if @result.success?
      flash[:success] = 'Company created'
    else
      flash[:error] = @result.messages[:error]
    end
    redirect_to superadmin_companies_path
  end

  def index
    @companies = Company.all
  end

end
