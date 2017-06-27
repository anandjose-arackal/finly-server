class UserGroup::Create < UserGroup::Base
  attr_accessor :name, :items

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end

    unless params&.dig(:name).present?
      add_message :error, 'Please provide a group name to create a group'
      return
    end
  end

  def init
    self.name = params[:name]
    self.items = params[:items]
    if self.items.blank?
      self.items = []
    end
    if self.items.is_a?(String)
      self.items = [self.items]
    end
    self.items = items.reject { |c| c.blank? }
  end

  def validate
    unless name.present?
      add_message :error, 'Please provide a group name to create a group'
      return
    end
    if items.present? and not items.is_a?(Array)
      add_message :error, 'Error creating Group Items. Please try again'
      return
    end
    if items.present? and items.map{|i| i.downcase}.uniq.length != items.length
      add_message :error, 'A Group cannot have multiple items with the same name'
    end
  end

  def process
    param = {
        name: self.name
    }
    if self.items.present?
      param[:user_group_items_attributes] = []
      self.items.each do |i|
        param[:user_group_items_attributes] << {name: i}
      end
    end
    user_group = user.company.user_groups.build param
    unless user_group.save
      add_message :error, user_group.errors.full_messages
    end
  end

end