class UserGroup::Item::Users::Remove < UserGroup::Item::Users::Base
  attr_accessor :item, :group, :user_ids

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:user_id).present?
      add_message :error, 'You have not selected any user to remove'
    end
  end

  def init
    users_presenter = UserGroup::Item::Show.(user, params)
    unless users_presenter.success?
      add_message :error, users_presenter.messages[:error]
      return
    end
    self.item = users_presenter.item
    self.group = users_presenter.group
    self.user_ids = params[:user_id]
  end

  def validate
    if self.item.blank? or self.group.blank? or self.user_ids.blank?
      add_message :error, 'Error loading configuration. Please try again'
    end
  end

  def process
    UserGroupItemMapping.with_group(self.group.id).with_group_item(self.item.id).with_user(self.user_ids).destroy_all
  end

end