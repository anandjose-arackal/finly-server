class UserGroup::Items::Create < UserGroup::Items::Base
  attr_accessor :names, :items

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:group_id).present?
      add_message :error, 'Group not found'
    end
    unless params&.dig(:names).present?
      add_message :error, 'Name cannot be blank'
    end
  end

  def init
    super
    return if self.user_group.blank?
    self.names = params[:names]
    if self.names.is_a?(String)
      self.names = [self.names]
    end
    if self.names.present? and self.user_group.present?
      self.items = []
      self.names.each do |name|
        self.items << user_group.user_group_items.build(name: name)
      end
    end
  end

  def validate
    if self.user_group.blank?
      add_message :error, 'Group not found'
      return
    end
    if self.items.blank?
      add_message :error, 'Name cannot be blank'
      return
    end
    if items.present? and self.names.map{|i| i.downcase}.uniq.length != self.names.length
      add_message :error, 'A Group cannot have multiple items with the same name'
      return
    end
    self.items.each do |item|
      unless item.valid?
        add_message :error, item.errors.full_messages
      end
    end
  end

  def process
    self.items.each do |item|
      item.save
    end
  end

end