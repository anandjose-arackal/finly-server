class Api::Vp::VendorsController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }

  def create
    @result = BankTransfer::Vendors::Create.(current_user, params)
    respond
  end

  def index
    @result = BankTransfer::Vendors::Index.(current_user, params)
    respond
  end

  def destroy

  end

end
