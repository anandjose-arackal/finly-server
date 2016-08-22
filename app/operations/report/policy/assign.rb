# assigning policy to a report
# params:
# report_id: id of the report to be updated
# policy_id: id of the policy to be assigned to the report

class Report::Policy::Assign < Report::Base

  attr_accessor :policy

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super()
    if params[:report_id].blank?
      errors << "Report id not passed"
    end
  end

  def init
    super()
    # todo - move this to policy retrieval service after it's implemented
    self.policy = Policy.find_by(id: params[:policy_id])
  end


  def authorize
    unless report.user_id == user.id
      errors << "You do not own this report."
    end

    if report.policy_id == policy.id
      errors << "Report is already assigned to this policy"
    end

    # checking if the user is actually this policy
    if policy and !user.policies.includes?(policy)
      errors << "You are not associated with this policy."
    end
  end

  def process
    unless report.update_attribute(:policy_id, params[:policy_id], submitted_at: nil)
      errors << report.errors.full_messages
    end
  end

  def post_process

  end
end