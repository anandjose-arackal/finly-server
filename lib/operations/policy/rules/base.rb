# Base class for rule creation and deletion and updation

class Policy::Rules::Base < Policy::Base
  attr_accessor :rule_params, :rule

  class Policy::Rules::Base::RulePresenter < Policy::Base::PolicyPresenter
    attr_accessor :rule

    def init
      self.rule = params[:rules]
    end
  end

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or policy passed."
    end
  end

  def init
    self.policy = user.policies.find_by(id: params[:policy_id] || params[:id])
  end

  def authorize
    unless user.admin? or user.policy_admin?(policy)
      messages[:error] << "You are not an admin or policy admin for this policy"
    end
  end

  def rule_parameters
    if params[:expense_rule]
      # params[:expense_rule][:greater_than_amount_attributes] = {value: params[:expense_rule][:amount], currency_id: Currency.first.id}
      params.require(:expense_rule).permit(:expense_rule_id, :category_id, :days_after, :expense_rule_type_id, :rule_type_id, :policy_id, greater_than_amount_attributes: [:value, :currency_id])
    elsif params[:budget_rule]
      # params[:budget_rule][:amount_attributes] = {value: params[:budget_rule][:amount], currency_id: Currency.first.id}
      params.require(:budget_rule).permit(:budget_rule_id, :category_id, :budget_period_id, :rule_type_id, :policy_id, amount_attributes: [:value, :currency_id])
    end
  end

  def success
     rule
  end

end