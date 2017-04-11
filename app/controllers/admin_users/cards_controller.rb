class AdminUsers::CardsController < ApplicationController

  # todo - temporary
  before_action :set_dummy_user

  def create
    @result = Admin::Cards::Create.(@dummy_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::Cards::Update.(@dummy_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show

  end

  # probably not required
  def destroy

  end

  private

  def set_dummy_user
    @dummy_user = AdminUser.first
  end
end