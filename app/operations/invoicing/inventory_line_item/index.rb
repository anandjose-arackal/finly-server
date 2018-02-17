class Invoicing::InventoryLineItem::Index < Invoicing::InventoryLineItem::Base

  attr_accessor :inventory_line_items

  class Invoicing::InventoryLineItem::Index::InventoryLineItemsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :inventory_line_items

    def init
      self.inventory_line_items = params[:inventory_line_items]
    end
  end

  def init
    self.inventory_line_items = user.company.inventory_line_items
  end

  def validate

  end

  def success
    params[:inventory_line_items] = self.inventory_line_items
    Invoicing::InventoryLineItem::Index::InventoryLineItemsPresenter.new(user, params, messages)
  end


end