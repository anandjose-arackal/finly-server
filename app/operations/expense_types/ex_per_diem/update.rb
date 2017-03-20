# configurable object can be either policy or company - will be decided based on the params passed
# parameters:
# {   per_diem: {name: "Something",
#                    rate_attributes: {value: "500",
#                                     currency_id: 1}
#
#               },
#     id: '2',
#     level_id: '1',
#     per_diem_level: 'policy'
# }

class ExpenseTypes::ExPerDiem::Update < ExpenseTypes::ExPerDiem::Base

  attr_accessor :configurable_object, :per_diem

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    case params[:per_diem_level]
      when 'company'
        self.per_diem = user.company.per_diems.find_from_id(params[:id])
      when 'policy'
        company = user.company
        policy = company.policies.find_from_id(params[:level_id])
        self.per_diem = policy.per_diems.find_from_id(params[:id])
      else
        # do nothing
    end
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