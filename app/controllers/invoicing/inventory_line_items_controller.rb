class Invoicing::InventoryLineItemsController < BaseControllers::WebBase

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
    render json: @result.count.as_json
  end

  def inventory_item_config
    @result = Invoicing::InventoryLineItem::InventoryItemConfig.(current_user, params)
    respond
  end

  def import
    @result = Invoicing::InventoryLineItem::Import.(current_user, params)
    respond
  end

  def import_template
    @result = Invoicing::InventoryLineItem::ImportTemplate.(current_user, params)
    respond
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end
end
