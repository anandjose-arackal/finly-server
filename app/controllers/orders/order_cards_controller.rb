class Orders::OrderCardsController < ApplicationController


  before_action :doorkeeper_authorize!
  
  def index
    @result = Orders::OrderCards::Index.(current_user, params)
    respond
  end

  def show
    @result = Orders::OrderCards::Show.(current_user, params)
    respond
  end

  def destroy
    @result = Orders::OrderCards::Cancel.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end
end