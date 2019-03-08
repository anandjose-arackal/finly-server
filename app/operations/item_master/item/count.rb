class ItemMaster::Item::Count < ItemMaster::Item::Base

  attr_accessor :count, :inventory_items

  class ItemMaster::Item::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end

  def init
    self.inventory_items = user.company.items
  end

  def process
    self.count = self.inventory_items.count
  end

  def success
    params[:count] = self.count
    ItemMaster::Item::Count::CountPresenter.new(user, params, messages)
  end
end