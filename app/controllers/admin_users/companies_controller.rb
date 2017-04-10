class AdminUsers::CompaniesController < ApplicationController

  allow_oauth!

  # before_action :authenticate_user!

  def new
    @states = State.all
  end

  def show
    @result = Admin::Companies::Show.(current_user, params)
  end

  def create
    @result = Admin::Companies::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Admin::Companies::Index.(current_user, params)
    respond
  end

  def update
    @result = Admin::Companies::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end


  private


end
