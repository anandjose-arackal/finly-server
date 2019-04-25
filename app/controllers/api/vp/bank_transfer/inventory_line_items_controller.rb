class Api::Vp::BankTransfer::InventoryItemsController < ApplicationController


  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }


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