class ItemMaster::Item::Show < ItemMaster::Item::Base

  attr_accessor :inventory_line_item

  def init
    id = params[:id] || params[:inventory_line_item_id]
    self.inventory_line_item = user.company.items.find_by(id: id)
  end

  def validate
    return if record_not_found
    validate_association
  end

  def success
    params[:inventory_line_item] = self.inventory_line_item
    ItemMaster::Item::Base::ItemPresenter.new(user, params, messages)
  end

  def validate_presence
    if self.inventory_line_item.blank? || inventory_line_item.company_id != user.company_id
      add_message :error, "Inventory item not found"
      return false
    end
    true
  end

  def record_not_found
    !validate_presence
  end

  def validate_association
    return if inventory_line_item.validate_if_admin?(user)
    # Creator ID not present on Item table
    # return if item.validate_if_owner?(user)
    return if inventory_line_item.validate_if_manager?(user)
    return if current_app == :fc
    raise_unauthorized_exception
  end

end