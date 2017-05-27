class UserGroup::Update < UserGroup::Base
  attr_accessor :name, :items, :groups_items_to_destroy

  def pre_validate
    super
    return if has_errors?
    unless params&.dig(:name)
      add_message :error, 'Name cannot be empty'
    end
  end

  def init
    super
    return unless self.user_group.present?
    user_group.name = params[:name]
    self.items = user_group.user_group_items
    # Store all the group item ids present. Remove the id which have been sent in params
    self.groups_items_to_destroy = self.items.pluck(:id)
    params&.dig(:items).each do |key, item_map|
      id = item_map[:id]
      name = item_map[:name]
      # If id is present, update the item name or else create a new item
      if id.present?
        items.each do |item|
          if item.id == id&.to_i and name.present?
            item.name = name
            groups_items_to_destroy.delete(item.id)
            break
          end
        end
      else
        items.build(name: name) if name.present?
      end
    end
  end

  def validate
    super
    return if has_errors?
    unless user_group.valid?
      add_message :error, user_group.errors.full_messages
      return
    end
    unless user_group.user_group_items.reject{|item| item.name.blank? }.uniq.size == user_group.user_group_items.size
      add_message :error, 'Group Item name cannot be empty'
      return
    end
    unless user_group.user_group_items.map{|item| item = item.name}.uniq.size == user_group.user_group_items.size
      add_message :error, 'A Group cannot have multiple items with the same name'
    end
  end

  def process
    # Destroy items marked for destruction
    self.items.with_id(self.groups_items_to_destroy).each do |item|
       item.destroy
    end
    user_group.save
  end

end