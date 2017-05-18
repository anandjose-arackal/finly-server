# Operation to destroy a particular Per Diem object
# params: {
#          id or per_diem_id: 'id of the per diem to be destroyed'
#          parent_type: "policy",
#          parent_id: "2" (id of the policy to which the per diem belongs)
# }
#

class ExpenseTypes::ExPerDiem::Destroy < ExpenseTypes::ExPerDiem::Base

  attr_accessor :per_diem

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:per_diem_id]
    policies = Policy::Index.(user, {view: 'admin'}).policies rescue []
    self.policy = policies.find_by(id: params[:policy_id])
    self.per_diem = policy.per_diems.with_id(id).first rescue nil
  end

  def authorize
    unless per_diem
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    unless per_diem.destroy
      messages[:error] = per_diem.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Per Diem deleted'
  end


end