class Company::PolicyExpenses < Company::Statement::Base

  attr_accessor :policies, :items

  # company admin or policy admin can access this operation
  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    self.items = {}
    if user.company_admin?
      self.policies = company.policies
    elsif user.policy_admin?
      self.policies = user.admin_policies
    end
  end

  def validate

  end

  def authorize

  end

  def process
    policies.each do |policy|
      r = Report.where(policy_id: policy.id).approved.where('approved_at > ? and approved_at <= ?', start_date, end_date)
      r.each do |report|
        items[policy.id] += report.total_amount
      end
    end
  end

end