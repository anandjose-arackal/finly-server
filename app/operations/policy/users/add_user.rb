# adding users to a policy
# params:
# policy_id: id of the policy for which the user needs to be added
# added_user_id: id of the user that us being added to this policy
# admin: true or false depending on if the user being added is being added as an admin or not.
#
# todo - generalize this for adding multiple users

class Policy::Users::AddUser < Policy::Base

  attr_accessor :added_user, :admin

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def init
    self.policy = user.policies.find_by(id: params[:policy_id])
    self.added_user = User.find_by(id: params[:added_user_id])
    self.admin = params[:admin]
  end

  def validate
    super()
    if policy and self.policy.users.find_by(id: added_user.id).present?
      errors << 'User is already part of the policy'
      return false
    end
    unless admin
      self.admin = false # setting user's admin status as false by default
    end
  end

  def authorize
    unless policy
      # check if it's an empty policy.
      self.policy = Policy.find_by(id: params[:policy_id])
      unless policy.users.blank?
        errors << "Policy not found."
      end
    end
    unless user.policy_admin?(policy) or user.admin?
      errors << "You are not a policy admin for this particular policy."
    end
  end

  def process
    # Add user to policy mapping
    policy.user_mapping.create(user: added_user, admin: admin)

    # Add user configuration - the user configuration is cloned from the default mapping, and additional rules have to be added separately.
    user.team_mapping.policy(nil).each do |item|
      cloned_item = item.dup
      cloned_item.policy_id = self.policy.id
      unless cloned_item.save
        errors << "User couldn't be added to the policy."
        return false
      end
    end
  end

  def post_process
    # mailer
  end
end