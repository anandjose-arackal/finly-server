# parent object can be either policy or company - will be decided based on the params passed
# parameters:
# {   per_diem: {name: "Something",
#                    rate_attributes: {value: "500",
#                                     currency_id: 1}
#
#               },
#     id: '2',
#     parent_id: '1',
#     parent_type: 'policy'
# }

class ExpenseTypes::ExPerDiem::Update < ExpenseTypes::ExPerDiem::Base

  attr_accessor :policy, :per_diem

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    policies = Policy::Index.(user, {view: 'admin'}).policies rescue []
    self.policy = policies.find_by(id: params[:policy_id])
    self.per_diem = policy.per_diems.find_from_id(params[:id])
  end

  def validate

  end

  def authorize
    super()
  end

  def process
    unless per_diem.update(per_diem_params)
      messages[:error] = per_diem.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Per Diem updated"
  end

  def success
    ExpenseTypes::ExPerDiem::Base::PerDiemPresenter.new(user, {per_diem: per_diem}, messages)
  end

end