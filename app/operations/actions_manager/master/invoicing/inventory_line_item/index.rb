class ActionsManager::Master::Invoicing::InventoryLineItem::Index < ActionsManager::Master::Base

  register_handle :inventory_line_item_index
  register_actions [:add_new_inventory_item, :dropdown, :import_inventory]

  def add_new_inventory_item
    true
  end

  def dropdown
    true
  end

  def import_inventory
    true
  end
  
end