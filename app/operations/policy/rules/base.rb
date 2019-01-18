# Base class for rule creation and deletion and updation

class Policy::Rules::Base < Policy::Base
  attr_accessor :rule_params, :rule

  class Policy::Rules::Base::RulePresenter < Policy::Base::PolicyPresenter
    attr_accessor :rule, :policy, :expense_rules, :budget_rules

    def init
      self.rule = params[:rule]
      self.policy = params[:policy]
      self.expense_rules = policy.expense_rules
      self.budget_rules = policy.budget_rules
    end
  end

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or policy passed"
    end
  end

  def init
    op = Policy::Index.(user, params)
    self.policy = op.policies.find_by(id: (params[:policy_id] or params[:id]))
  end

  def authorize
    unless user.admin? or user.policy_admin?(policy)
      messages[:error] << "You are not an admin or policy admin for this policy"
    end
  end

  def rule_parameters
    if params[:expense_rule]
      params.require(:expense_rule).permit(:expense_rule_id, :category_id, :days_after,
                                           :expense_rule_type_id, :rule_type_id, :policy_id,
                                           {greater_than_amount_attributes: [:value, :currency_id]},
                                           {budget_rule_field_mappings_attributes: [:field_configuration_id, :field_drop_down_item_id]})
    elsif params[:budget_rule]
      params.require(:budget_rule).permit(:budget_rule_id, :period_id, :rule_type_id,
                                          :policy_id, :include_reimbursable,
                                          {budget_rule_category_mappings_attributes: [:category_id]},
                                          {budget_rule_department_mappings: [:department_id]},
                                          {expense_types_ids: []},
                                          {amount_attributes: [:value, :currency_id]},
                                          {with_receipt_amount_attributes: [:value, :currency_id]},
                                          {without_receipt_amount_attributes: [:value, :currency_id]},
                                          {budget_rule_field_mappings_attributes: [:field_configuration_id, :field_drop_down_item_id]})
    end
  end

  def success
    Policy::Rules::Base::RulePresenter.new(user, {rule: rule, policy: policy}, messages)
  end

end