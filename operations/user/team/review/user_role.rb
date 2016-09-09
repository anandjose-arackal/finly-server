class User::Team::Review::UserRole < BaseOperation

  def self.call(user, obj)
    return nil unless obj.present? and user.present? and (obj.is_a?(CardLoadRequest) or obj.is_a?(Report))
    uts = UserTeamService.new(user)
    if user.id == obj.user.id
      return UserRole.employee_id
    end
    if user.manager? and uts.manager_for?(obj)
      return UserRole.manager_id
    elsif user.finance_manager? and uts.finance_manager_for?(obj)
      return UserRole.finance_manager_id
    end
  end

end