class UserGroup::Update < UserGroup::Base
  attr_accessor :name, :items

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
    params&.dig(:items).each do |key, item_map|
      id = item_map[:id]
      name = item_map[:name]
      # If id is present, update the item name or else create a new item
      if id.present?
        items.each do |item|
          if item.id == id&.to_i
            item.name = name
          end
        end
      else
        items.build(name: name)
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
    unless user_group.user_group_items.map{|item| item = item.name}.uniq.size == user_group.user_group_items.size
      add_message :error, 'A Group cannot have multiple items with the same name'
    end
  end

  def process
    user_group.save
  end

end