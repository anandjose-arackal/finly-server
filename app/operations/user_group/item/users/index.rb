class UserGroup::Item::Users::Index < UserGroup::Item::Users::Base
  attr_accessor :item, :users

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:id).present? or params&.dig(:item_id).present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    company_groups = user.company.user_groups.pluck(:id)
    item_id = (params[:id] or params[:item_id])
    self.item = UserGroupItem.with_user_group(company_groups).find_by(id: item_id)
    self.users = self.item&.users
  end

  def validate
    if self.item.blank?
      add_message :error, 'Group Item not found'
    end
  end

  def success
    params[:item] = self.item
    params[:users] = self.users
    UserGroup::Item::Users::Index::SuccessPresenter.new(user, params, messages)
  end

  class UserGroup::Item::Users::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :item, :users

    def init
      self.item = params[:item]
      self.users = params[:users]
    end

  end

end