class Company::Statement::PolicyExpenses < Company::Statement::Base

  attr_accessor :policies, :items

  # company admin or policy admin can access this operation
  def authorized_user_types
    [:company_admin]
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
    self.policies = company.policies
    # if user.company_admin?
    #   self.policies = company.policies
    # elsif user.policy_admin?
    #   self.policies = user.admin_policies
    # end
  end

  def validate

  end

  def authorize

  end

  def process
    policies.each do |policy|
      card_total = 0
      cash_total = 0
      if policy.name.nil?
        name = "None"
        totals = default_policy_total(policy)
        card_total = totals[0]
        cash_total = totals[1]
      else
        name = policy.name
        r = Report.where(policy_id: policy.id).processed.where('approved_at >= ? and approved_at <= ?', start_date, end_date)
        r.each do |report|
          card_total += report.total_amount(:only_card_expenses)
        end
        r.each do |report|
          cash_total += report.total_amount(:only_manual_expenses)
        end
      end
      self.items << {name: name, total: (card_total + cash_total), via_card: card_total, via_cash: cash_total}
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
    card_total = 0
    cash_total = 0
    r.each do |report|
      card_total += report.total_amount(:only_card_expenses)
      cash_total += report.total_amount(:only_cash_expenses)
    end
    [card_total, cash_total]
  end

end
