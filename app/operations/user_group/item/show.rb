class UserGroup::Item::Show < UserGroup::Item::Users::Base
  attr_accessor :item, :group, :users

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:group_id).present?
      add_message :error, 'Group not found'
      return
    end
    unless params&.dig(:id).present? or params&.dig(:item_id).present?
      add_message :error, 'Group Item not found'
      return
    end
  end

  def init
    self.group = user.company.user_groups.find_by(id: params[:group_id])
    return if self.group.blank?
    item_id = (params[:id] or params[:item_id])
    self.item = UserGroupItem.with_user_group(group.id).find_by(id: item_id)
    self.users = self.item&.users
  end

  def validate
    if self.group.blank?
      add_message :error, 'Group not found'
      return
    end
    if self.item.blank?
      add_message :error, 'Group Item not found'
      return
    end
  end

  def success
    params[:group] = self.group
    params[:item] = self.item
    params[:users] = self.users
    UserGroup::Item::Show::SuccessPresenter.new(user, params, messages)
  end

  class UserGroup::Item::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :group, :item, :users

    def init
      self.group = params[:group]
      self.item = params[:item]
      self.users = params[:users]
    end

  end

end