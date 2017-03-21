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

  attr_accessor :parent_object, :per_diem

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    case params[:parent_type]
      when 'company'
        self.parent_object = user.company
      when 'policy'
        company = user.company
        self.parent_object = company.policies.find_from_id(params[:parent_id])
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
    self.per_diem = parent_object.per_diems.build(per_diem_params)
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