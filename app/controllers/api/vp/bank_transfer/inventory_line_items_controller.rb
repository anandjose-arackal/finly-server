class Api::Vp::BankTransfer::InventoryItemsController < BaseControllers::ApiBase


  protect_from_forgery with: :null_session



  def index
    @result = Invoicing::InventoryLineItem::Index.(current_user, params)
    respond
  end

  def show
    @result = Invoicing::InventoryLineItem::Show.(current_user, params)
    respond
  end

  def update
    @result = Invoicing::InventoryLineItem::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def create
    @result = Invoicing::InventoryLineItem::Create.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::InventoryLineItem::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end
