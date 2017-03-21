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
    case params[:parent_type]
      when 'company'
        self.per_diem = company.per_diems.find_from_id(id) rescue nil
      when 'policy'
        policy = company.policies.find_from_id(params[:parent_id])
        self.per_diem = policy.per_diems.find_from_id(id)
      else
        self.per_diem = nil
    end
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

  def success
    true
  end


end