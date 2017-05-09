class UserGroup::Users < UserGroup::Base
  attr_accessor :filter_group_items, :selected_users

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.filter_group_items = []
    params[:filter_group_items]&.each do |key, value|
      self.filter_group_items << value
    end
  end

  def validate

  end

  def process
    users = user.company.users
    # user_ids = users.pluck(:id)
    groups = user.company.user_groups
    group_ids = groups.pluck(:id)
    group_items = UserGroupItem.with_user_group(group_ids)
    group_items_ids = group_items.pluck(:id)
    exclude_item_ids = group_items_ids - self.filter_group_items
    include_users =  UserGroupItemMapping.with_group_item(self.filter_group_items).pluck(:user_id)
    exclude_users = UserGroupItemMapping.with_group_item(exclude_item_ids).pluck(:user_id)
    self.selected_users = users.without_id(exclude_users).with_id(include_users)
  end

  def success
    params[:selected_users] = self.selected_users
    UserGroup::Users::SuccessPresenter.new(user, params, messages)
  end

  class UserGroup::Users::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_users

    def init
      self.selected_users = params[:selected_users]
    end

  end

end