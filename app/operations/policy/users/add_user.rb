# adding users to a policy
# params:
# policy_id: id of the policy for which the user needs to be added
# added_user_id: id of the user that us being added to this policy
# admin: true or false depending on if the user being added is being added as an admin or not.
#

class Policy::Users::AddUser < Policy::Base

  attr_accessor :added_users, :admin

  def authorized_user_types
    [:policy_admin, :admin, :vendor_payments_admin]
  end

  def init
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id] || params[:id])
    ids = params[:user_id]
    unless ids.is_a?(Array)
      ids = ids.split(',')
    end
    self.added_users = user.company.users.with_id(ids)
    self.admin = params[:admin]
  end

  def validate
    super()
    added_users.each do |added_user|
      if self.policy.users.find_by(id: added_user.id).present?
        added_users.reject {|user| user.id == added_user.id}
      end
    end

    unless admin
      self.admin = false # setting user's admin status as false by default
    end
  end

  def authorize
    unless policy
      # check if it's an empty policy, for adding a user for the first time
      self.policy = Policy.find_by(id: params[:policy_id])
      unless policy.users.blank?
        messages[:error] << "Policy not found"
      end
    end
  end

  def process
    added_users.each do |added_user|
      # Add user to policy mapping
      policy.user_mapping.create(user: added_user, admin: admin)

      # Add user configuration - the user configuration is cloned from the default mapping, and additional rules have to be added separately.
      added_user.team_mapping.policy(added_user.company.default_policy.id).each do |item|
        cloned_item = item.deep_clone
        cloned_item.policy_id = self.policy.id
        if cloned_item.greater_than_amount.present?
          amount = cloned_item.greater_than_amount.deep_clone
          amount.save
          cloned_item.greater_than_amount = amount
        end
        unless cloned_item.save
          messages[:error] << "Some users couldn't be added to the policy"
          return false
        end
      end
    end
  end

  def post_process
    messages[:success] << 'Users added to policy'
  end

  def success
    Policy::Base::PolicyPresenter.new(user, {policy: policy}, messages)
  end

end