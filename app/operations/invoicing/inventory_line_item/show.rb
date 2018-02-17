class Invoicing::InventoryLineItem::Show < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_line_item

  class Invoicing::InventoryLineItem::Show::ItemPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :inventory_item

    def init
      self.inventory_item = params[:inventory_line_item]
    end

  end

  def init
    id = params[:id] || params[:inventory_line_item_id]
    self.inventory_line_item = user.company.inventory_line_items.find_by(id: id)
  end

  def validate
    if self.inventory_line_item.blank?
      add_message :error, "Inventory item not found"
      return
    end
  end

  def success
    params[:inventory_line_item] = self.inventory_line_item
    Invoicing::InventoryLineItem::Show::ItemPresenter.new(user, params, messages)
  end
end