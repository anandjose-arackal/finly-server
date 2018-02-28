class Invoicing::InventoryLineItem::Count < Invoicing::InventoryLineItem::Base

  attr_accessor :count, :inventory_items

  class Invoicing::InventoryLineItem::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end

  def init
    self.inventory_items = user.company.inventory_line_items
  end

  def process
    self.count = self.inventory_items.count
  end

  def success
    params[:count] = self.count
    Invoicing::InventoryLineItem::Count::CountPresenter.new(user, params, messages)
  end
end