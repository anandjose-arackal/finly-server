class Invoicing::InventoryLineItem::Create < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_line_item, :inventory_item_parameters

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:invoicing, :inventory_line_item], :validate, self)
        }
    }
  end

  def init
    self.inventory_item_parameters = inventory_item_params
  end

  def process
    self.inventory_line_item = user.company.inventory_line_items.build(self.inventory_item_parameters)
    unless self.inventory_line_item.save
      add_message :error, self.inventory_line_item.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Inventory item created"
  end

  def success
    params[:inventory_line_item] = self.inventory_line_item
    Invoicing::InventoryLineItem::Base::ItemPresenter.new(user, params, messages)
  end
end