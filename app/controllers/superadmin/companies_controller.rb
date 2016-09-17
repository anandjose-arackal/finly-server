class Superadmin::CompaniesController < ApplicationController

  before_action :authenticate_user!

  def new

  end

  def show
    @result = Company::Show.new(current_user, params).run
  end

  def create
    create_op = Company::Create.new(current_user, params)
    @result = create_op.run
    # temporary rendering for html testing.
    if @result.success?
      flash[:success] = "Company created"
    else
      flash[:error] = "Failed. Try again"
    end
    redirect_to request.referrer
  end

  def add_admin
    add_admin_op = Company::Create.new(current_user, params)
    @result = add_admin_op.run
    # temporary rendering for html testing.
    if @result.success?
      flash[:success] = "Company created"
    else
      flash[:error] = "Failed. Try again"
    end
    redirect_to request.referrer
  end

  def index
    @companies = Company.all
  end


end
