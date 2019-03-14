class ItemMaster::Item::Show < ItemMaster::Item::Base

  attr_accessor :inventory_line_item

  def init
    id = params[:id] || params[:inventory_line_item_id]
    self.inventory_line_item = user.company.items.find_by(id: id)
  end

  def validate
    if self.inventory_line_item.blank?
      add_message :error, "Inventory item not found"
      return
    end
  end

  def success
    params[:inventory_line_item] = self.inventory_line_item
    ItemMaster::Item::Base::ItemPresenter.new(user, params, messages)
  end
end