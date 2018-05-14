class Api::Vp::VendorController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }

  def create
    @result = BankTransfer::Vendors::Create.(current_user, params)
    respond_success_failure
  end

end
