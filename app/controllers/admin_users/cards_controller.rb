class AdminUsers::CardsController < ApplicationController

  # todo - temporary

  before_action -> { doorkeeper_authorize! :web}

  def create
    @result = Admin::Cards::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::Cards::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def block
    if params[:card][:active] == '0'
      @result = Admin::Cards::Block.(current_user, params)
    elsif params[:card][:active] == '1'
      @result = Admin::Cards::Unblock.(current_user, params)
    end
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

end