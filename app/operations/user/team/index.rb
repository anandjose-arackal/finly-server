# action that gives the list of users in a particular user's team
# params:
# role_id: the role of the user viewing the team
# if role_id is not passed, the view of the particular user is used

class User::Team::Index < User::Team::Base
  attr_accessor :role_id

  has_scope :filter_search
  has_scope :filter_role
  has_scope :filter_state

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    case role_id
      when UserRole.admin_id
        unless user.admin?
          messages[:error] << 'User is not an Admin'
          raise_unauthorized_exception
        end
      when UserRole.finance_manager_id
        unless user.finance_manager?
          messages[:error] << 'User is not a Finance Manager'
          raise_unauthorized_exception
        end
      when UserRole.manager_id
        unless user.manager?
          messages[:error] << 'User is not a Manager'
          raise_unauthorized_exception
        end
      else
        #Nothing
    end
  end

  def validate
    unless role_id.present?
      messages[:error] << 'User role not defined'
    end
  end

  def process
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
    user_ids += UserManagerMapping.send(manager_association, user.id).pluck(:user_id)
    # adding members invited by this particular user
    user_ids += user.company.users.invited_by(user.id)
    user_ids.uniq! if user_ids.present?
    # if user_ids.present?
      self.response = user.company.users.with_id(user_ids)
    # end
  end

  def retrieve
    apply_scopes(self.response, params) if self.response.present?
  end


  private
  def admin_team
    clear_messages
    if user.company_admin?
      return user.company.users
    elsif user.policy_admin?
      users = user.company.users
      policies = user.admin_policies.pluck(:id)
      if policies.present?
        return users.with_id(PolicyUserMapping.with_policy(policies).pluck(:user_id))
      end
    end
    messages[:error] << 'User is not an admin'
    false
  end

end