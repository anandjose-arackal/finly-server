# Base class for rule creation and deletion and updation

class Policy::Rule::Base < Policy::Base

  attr_accessor :rule_params, :rule

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or policy passed."
    end
  end

  def init
    self.policy = Policy.find_by(id: params[:policy_id])
  end

  def authorize
    unless user.policy_admin?(policy)
      errors << "You are not a policy admin for this policy"
    end
  end

  def rule_parameters
    # todo - recheck the actual parameters that are being passed and whitelist them individually
    params.require(:rule).permit!
  end

  def retrieve
    if is_success?
      return rule
    else
      return false
    end
  end

end