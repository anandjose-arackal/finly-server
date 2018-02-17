class Invoicing::InventoryLineItem::Destroy < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_item

  def init
    id = params[:id] || params[:inventory_item_id]
    self.inventory_item = user.company.inventory_line_items.find_by(id: id)
  end

  def process
    unless self.inventory_item.destroy
      add_message :error, self.inventory_item.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Inventory item created"
  end

end