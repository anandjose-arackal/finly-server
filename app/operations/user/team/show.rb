class User::Team::Show < User::Team::Base
  attr_accessor :role_id

  class User::Team::Show::ShowPresenter < User::Team::Base::TeamPresenter

    attr_accessor :team

    def initialize(user, params)
      self.team = params[:team]

    end
  end

  def initialize(user, role_id, params={})
    super(user, params)
    self.role_id = role_id
  end

  def self.call(user, role_id, params={})
    self.new(user, role_id, params).run
  end

  def pre_validate
    errors.clear
    unless user.present?
      errors << 'User not found'
    end
    unless role_id.present?
      errors << 'User role not defined'
    end
  end

  def authorize
    case role_id
      when UserRole.admin_id
        unless user.admin?
          errors << 'User is not an Admin'
          raise_unauthorized_exception
        end
      when UserRole.finance_manager_id
        unless user.finance_manager?
          errors << 'User is not a Finance Manager'
          raise_unauthorized_exception
        end
      when UserRole.manager_id
        unless user.manager?
          errors << 'User is not a Manager'
          raise_unauthorized_exception
        end
      else
        #Nothing
    end
  end

  def process
    indirect_associations = params[:indirect_associations]
    user_ids = []
    manager_association = nil
    approves_to_association = nil
    case role_id
      when UserRole.admin_id
        self.response = admin_team
        return
      when UserRole.finance_manager_id
        manager_association = :has_finance_manager
        approves_to_association = :has_approves_finance_to
      when UserRole.manager_id
        manager_association = :has_manager
        approves_to_association = :has_approves_to
    end
    return if manager_association.blank? or approves_to_association.blank?
    user_ids += UserManagerMapping.send(manager_association, user.id).pluck(:id)
    approves_to_ids = UserManagerMapping.send(approves_to_association, user.id).pluck(:id)
    while indirect_associations and approves_to_ids.present?
      user_ids += UserManagerMapping.send(manager_association, approves_to_ids).pluck(:id)
      approves_to_ids = UserManagerMapping.send(approves_to_association, approves_to_ids).pluck(:id)
    end
    user_ids.uniq! if user_ids.present?
    if user_ids.present?
      self.response = user.company.users.with_id(user_ids)
    end
  end

  def retrieve
    if is_success?
      team_presenter = User::Team::Show::ShowPresenter.new(user, {team: response})
      return team_presenter
    else
      return false
    end
  end

  private

  def admin_team
    errors.clear
    if user.company_admin?
      return user.company.users
    elsif user.policy_admin?
      users = user.company.users
      policies = user.admin_policies.pluck(:id)
      if policies.present?
        return users.with_id(PolicyUserMapping.with_policy(policies).pluck(:user_id))
      end
    end
    errors << 'User is not an admin'
    false
  end

end