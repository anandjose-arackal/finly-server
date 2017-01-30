class Company::Statement::PolicyExpenses < Company::Statement::Base

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
    super()
    self.company = user.company
    self.items = []
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
      total = 0
      if policy.name.nil?
        self.items << default_policy_total(policy)
      else
        r = Report.where(policy_id: policy.id).processed.where('approved_at >= ? and approved_at <= ?', start_date, end_date)
        r.each do |report|
          total += report.total_amount
        end
        self.items << {policy => total}
      end
    end
  end

  def success
    Company::Statement::PolicyExpenses::PolicyExpensePresenter.new(user, {items: items}, messages)
  end

  class Company::Statement::PolicyExpenses::PolicyExpensePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :items

    def init
      self.items = params[:items]
    end
  end


  private

  def default_policy_total(policy)
    user_ids = user.company.users.pluck(:id)
    r = Report.where(user_id: user_ids).where(policy_id: nil).processed.where('approved_at > ? and approved_at <= ?', start_date, end_date)
    total = 0
    r.each do |report|
      total += report.total_amount
    end
    {policy => total}
  end

end
