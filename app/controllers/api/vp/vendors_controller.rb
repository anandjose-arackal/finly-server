class Api::Vp::VendorsController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  def create
    @result = BankTransfer::Vendors::Create.(current_user, params)
    respond
  end

end
