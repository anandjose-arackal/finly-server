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
    self.items = user_group.items
    params&.dig(:items).each do |item_map|
      id = item_map[:id]
      name = item_map[:name]
      if id.present?
        items.find_by(id: id)&.name = name
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
    end
  end

  def process
    unless user_group.update(name: params[:name])
      add_message :error, user_group.errors.full_messages
    end
  end

end