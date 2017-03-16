class ExpenseTypes::ExPerDiem::Destroy < ExpenseTypes::PerDiem::Base

  attr_accessor :per_diem_config

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
        self.per_diem_config = user.company.per_diem_expense_config
      when 'policy'
        policies = Policy::Index.(user, {view: 'policy_admin'}).policies rescue []
        self.per_diem_config = policies.find_from_id(params[:parent_id]).per_diem_expense_config rescue nil
      else
        self.per_diem_config = nil
    end
  end

  def authorize
    unless per_diem_config
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    unless per_diem_config.destroy
      messages[:error] = per_diem_config.errors.full_messages
    end
  end


end