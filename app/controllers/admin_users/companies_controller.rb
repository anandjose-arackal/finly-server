class AdminUsers::CompaniesController < ApplicationController

  allow_oauth!

  # before_action :authenticate_user!

  # todo - temporary
  before_action :set_dummy_user

  def new
    @states = State.all
  end

  def show
    @result = Admin::Companies::Show.(@dummy_user, params)
    respond
  end

  def create
    @result = Admin::Companies::Create.(@dummy_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    debugger
    @result = Admin::Companies::Index.(@dummy_user, params)
    respond
  end

  def update
    @result = Admin::Companies::Update.(@dummy_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end


  private

  def set_dummy_user
    @dummy_user = AdminUser.first
  end

end
