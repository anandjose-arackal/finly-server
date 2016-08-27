# action to create policies
# params:
# name: Name of the policy that needs to be created.

class Policy::Create < Policy::Base

  attr_accessor :company, :cloned_policy

  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank?
      errors << "NO user passed."
    end
  end

  def init
    self.company = user.company
  end

  def process
    self.cloned_policy = company.policies.default.first.deep_clone except: [:users, :user_mapping]
    cloned_policy.name = name
    cloned_policy.default = false
    unless cloned_policy.save
      self.policy = cloned_policy
      errors << cloned_policy.errors.full_messages
      return false
    end
  end

  def post_process
    if is_success?
      # todo - change this to operation once Policy User service is implemented
      user_service = PolicyUserService.new(cloned_policy)
      # Add the creating user as admin
      user_service.add_user user, true
      return cloned_policy
    end
  end

end