class Invoicing::InventoryLineItemsController < ApplicationController

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

  def count
    @result = Invoicing::InventoryLineItem::Count.(current_user, params)
    respond
  end
end