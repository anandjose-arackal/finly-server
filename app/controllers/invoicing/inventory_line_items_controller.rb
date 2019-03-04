class Invoicing::InventoryLineItemsController < ApplicationController

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

  def count
    @result = ItemMaster::Item::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def inventory_item_config
    @result = ItemMaster::Item::ItemConfig.(current_user, params)
    respond
  end

  def import
    @result = ItemMaster::Item::Import.(current_user, params)
    respond
  end

  def import_template
    @result = ItemMaster::Item::ImportTemplate.(current_user, params)
    respond
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

end