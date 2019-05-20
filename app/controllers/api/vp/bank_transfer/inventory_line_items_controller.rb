class Api::Vp::BankTransfer::InventoryItemsController < BaseControllers::ApiBase


  protect_from_forgery with: :null_session



  def index
    @result = ItemMaster::Item::Index.(current_user, params)
    respond
  end

  def show
    @result = ItemMaster::Item::Show.(current_user, params)
    respond
  end

  def update
    @result = ItemMaster::Item::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def create
    @result = ItemMaster::Item::Create.(current_user, params)
    respond
  end

  def destroy
    @result = ItemMaster::Item::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end
