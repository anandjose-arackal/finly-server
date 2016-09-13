class ReceiptsController < ApplicationController

  before_action :authenticate_user!


  def index
    @result = Receipt::Index.(current_user, params)
    respond
  end

  def create
    @result =  Receipt::Create.(current_user, params)
    respond response: :success
  end

  def destroy
    @result = Receipt::Create.(current_user, params)
    respond response: :success
  end

  def update
    @result = Receipt::Update.(current_user, params)
    respond response: :success
  end


end
