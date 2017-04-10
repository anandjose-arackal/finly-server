class AdminUsers::CompaniesController < ApplicationController

  allow_oauth!

  # before_action :authenticate_user!

  def new
    @states = State.all
  end

  def show
    @result = Admin::Company::Show.(current_user, params)
  end

  def create
    @result = Admin::Company::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Admin::Company::Index.(current_user, params)
    respond
  end

  def update
    @result = Admin::Company::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end


  private


end
