class Invoicing::InventoryLineItem::Index < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_line_items

  class Invoicing::InventoryLineItem::Index::InventoryLineItemsPresenter < BaseOperation::BasePresenter::SuccessPResenter


  end

  def init
    self.inventory_line_items = user.company.inventory_line_items
  end


end