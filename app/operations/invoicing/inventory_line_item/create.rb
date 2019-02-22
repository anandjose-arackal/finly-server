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

  def validate
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
    self.inventory_line_item = user.company.inventory_line_items.build(self.inventory_item_parameters)
    if  self.inventory_line_item.save
      # if inventory_item_parameters[:artifacts].present?
      #   artifact = inventory_line_item.artifacts.build
      #   # artifact.attachment = File.new(file_path)
      #   unless artifact.save
      #     add_message :error, "Upload failed, some error occurred!"
      #   end
      # end
    else
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