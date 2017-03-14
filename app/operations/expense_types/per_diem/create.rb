class ExpenseTypes::PerDiem::Create < ExpenseTypes::Base

  attr_accessor :company, :per_diem

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
  end

  def authorize
    unless company
      raise_unauthorized_exception
    end
  end

  def process
    self.per_diem = company.per_diems.build(per_diem_params)
    unless per_diem.save
      messages[:error] = per_diem.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Per Diem created"
  end

  def success
    Company::Configuration::ExpenseTypes::PerDiem::Base::PerDiemPresenter.new(user, {per_diem: per_diem}, messages)
  end
end