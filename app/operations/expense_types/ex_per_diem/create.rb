# configurable object can be either policy or company - will be decided based on the params passed
# parameters:
# {   per_diem: {name: "Something",
#                    rate_attributes: {value: "500",
#                                     currency_id: 1}
#
#               },
#     parent_id: '1',
#     parent_type: 'company'
# }

class ExpenseTypes::ExPerDiem::Create < ExpenseTypes::ExPerDiem::Base

  attr_accessor :per_diem, :create_params

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters'
    end
  end

  def init
    self.create_params = per_diem_params
    policies = Policy::Index.(user, {view: 'admin'}).policies rescue []
    self.policy = policies.find_by(id: params[:policy_id])
  end

  def validate

  end

  def authorize
    super()
  end

  def pre_process
    self.create_params[:rate_attributes][:currency_id] = policy.base_currency_id
  end

  def process
    self.per_diem = policy.per_diems.build(create_params)
    unless per_diem.save
      messages[:error] = per_diem.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Per Diem created"
  end

  def success
    ExpenseTypes::ExPerDiem::Base::PerDiemPresenter.new(user, {per_diem: per_diem}, messages)
  end
end