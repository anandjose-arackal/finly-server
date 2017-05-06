class UserGroup::Items::Base < UserGroup::Base
  attr_accessor :user_group_item

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    super
    return if has_errors?
    unless params.dig(:item_id).present?
      add_message :error, 'Group Item not found'
      return
    end
  end

  def init
    super
    return unless user_group.present?
    item_id = params[:item_id]
    self.user_group_item = user_group.user_group_items.find_by(id: item_id) if item_id.present?
  end

  def validate
    super
    return if has_errors?
    if user_group_item.blank?
      add_message :error, 'Group Item not found'
    end
  end

end