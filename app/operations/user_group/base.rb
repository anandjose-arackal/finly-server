class UserGroup::Base < BaseOperation
  attr_accessor :user_group

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:id).present?
      add_message :error, 'Group not found'
    end
  end

  def init
    id = params&.dig(:id)
    if id.present?
      self.user_group = user.company.user_groups.find_by(id: id)
    end
  end

  def validate
    if self.user_group.blank?
      add_message :error, 'Group not found'
    end
  end

end