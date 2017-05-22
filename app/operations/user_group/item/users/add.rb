class UserGroup::Item::Users::Add < UserGroup::Item::Users::Base
  attr_accessor :selected_users, :item, :group

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:user_id).present?
      add_message :error, 'You have not selected any user to add'
    end
  end

  def init
    addable_presenter = UserGroup::Item::Users::AddableUsers.(user, params)
    unless addable_presenter.success?
      add_message :error, addable_presenter.messages[:error]
      return
    end
    self.item = addable_presenter.item
    self.group = addable_presenter.group
    self.selected_users = addable_presenter.addable_users.with_id(params[:user_id])
  end

  def validate
    if self.item.blank? or self.group.blank? or self.selected_users.blank?
      add_message :error, 'Error loading configuration. Please try again'
    end
  end

  def process
    selected_users.each do |user|
      user.user_group_item_mappings.create user_group_item_id: self.item.id, user_group_id: self.group.id
    end
  end

end