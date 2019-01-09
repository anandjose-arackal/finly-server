class Invoicing::InventoryLineItem::Update < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_item, :inventory_item_parameters

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:invoicing, :inventory_line_item], :validate, self)
        }
    }
  end

  def init
    id = params[:id] || params[:inventory_item_id]
    self.inventory_item = user.company.inventory_line_items.find_by(id: id)
    self.inventory_item_parameters = inventory_item_params
  end

  def validate
    if self.inventory_item.blank?
      add_message :error, "Inventory item not found"
      return
    end

    supply_item_type_id = inventory_item_params[:supply_item_type_id]

    if supply_item_type_id.present?
      supply_item_type = SupplyItemType.name_for(supply_item_type_id.to_i)

      if supply_item_type == 'po_item'
        unless user.permission.crud_inventory_item_po
          add_message :error, "You don't have permission for this action"
        end
      elsif supply_item_type == 'non_po_item'
        unless user.permission.crud_inventory_item_non_po
          add_message :error, "You don't have permission for this action"
        end
      end
    end
  end

  def process
    unless self.inventory_item.update(self.inventory_item_parameters)
      add_message :error, self.inventory_item.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Inventory item updated!"
  end
end