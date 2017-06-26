class UserGroup::Users < UserGroup::Base
  attr_accessor :filter_group_items, :selected_users

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.filter_group_items = params[:filter_group_items]
    unless self.filter_group_items.is_a?(Array)
      self.filter_group_items = [self.filter_group_items]
    end
  end

  def validate

  end

  def process
    # users = user.company.users
    # # user_ids = users.pluck(:id)
    # groups = user.company.user_groups
    # group_ids = groups.pluck(:id)
    # group_items = UserGroupItem.with_user_group(group_ids)
    # group_items_ids = group_items.pluck(:id)
    # exclude_item_ids = group_items_ids - self.filter_group_items
    # exclude_users = UserGroupItemMapping.with_group_item(exclude_item_ids).pluck(:user_id)
    #
    # involved_groups_count = group_items.with_id(filter_group_items).user_group_count
    #
    # if filter_group_items.present?
    #   include_users =  UserGroupItemMapping.with_group_item(self.filter_group_items).having_greater_than_association_count(involved_groups_count).pluck(:user_id)
    #   users = users.with_id(include_users)
    # end
    #
    # # Include users assigned to the selected group items. Exclude other users who belong to other groups items
    # self.selected_users = users.without_id(exclude_users)

    self.selected_users = user.company.users
    group_ids = user.company.user_groups.pluck(:id)
    group_items = UserGroupItem.with_user_group(group_ids).with_id(self.filter_group_items)
    selected_group_ids = group_items.pluck(:user_group_id).uniq
    selected_group_ids.each do |id|
      user_ids = UserGroupItemMapping.with_group(id).with_group_item(self.filter_group_items).pluck(:user_id)
      self.selected_users = self.selected_users.with_id(user_ids)
    end
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