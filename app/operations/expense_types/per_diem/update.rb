class ExpenseTypes::PerDiem::Update < ExpenseTypes::PerDiem::Base

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
    ExpenseTypes::PerDiem::Base::PerDiemPresenter.new(user, {per_diem: per_diem}, messages)
  end

end

