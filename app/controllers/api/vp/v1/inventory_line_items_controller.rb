class Api::Vp::V1::InventoryLineItemsController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  def create
    @result = ItemMaster::Item::Create.(current_user, params)
    respond
  end

  def index
    @result = ItemMaster::Item::Index.(current_user, params)
    respond
  end

  def destroy
    @result = ItemMaster::Item::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end
