class UserTeam::BatchUpdate::Base < UserTeam::Base
  attr_accessor :users

  def authorized_user_types
    [:company_admin]
  end

  def init
    super
    return if user_team.blank?
    self.users = UserGroup::Users.(user, filter_group_items: self.user_team.user_group_items.pluck(:id).uniq)&.selected_users
  end

end