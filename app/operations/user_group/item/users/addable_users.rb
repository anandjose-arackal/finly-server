class UserGroup::Item::Users::AddableUsers < UserGroup::Item::Users::Base
  attr_accessor :addable_users, :item, :group

  def init
    item_presenter = UserGroup::Item::Show.(user, params)
    unless item_presenter.success?
      add_message :error, item_presenter.messages[:error]
      return
    end
    self.item = item_presenter.item
    self.group = item_presenter.group
  end

  def validate
    if self.item.blank? or self.group.blank?
      add_message :error, 'Group not found'
      return
    end
  end

  def process
    users_with_group_item_mapping = UserGroupItemMapping.with_group(group.id).pluck(:user_id)
    self.addable_users = user.company.users.without_id(users_with_group_item_mapping)
  end

  def success
    params[:item] = self.item
    params[:group] = self.group
    params[:addable_users] = self.addable_users
    UserGroup::Item::Users::AddableUsers::SuccessPresenter.new(user, params, messages)
  end

  class UserGroup::Item::Users::AddableUsers::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :addable_users, :item, :group

    def init
      self.item = params[:item]
      self.group = params[:group]
      self.addable_users = params[:addable_users]
    end

  end

end