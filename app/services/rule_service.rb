class RuleService < BaseService

  def initialize(current_user)
    super()
    @user = current_user
  end

  def add_expense_rule(params)
    # retrieving policies from the policy retrieval service
    policy = retrieve_policy params[:policy_id]
    rule_params = retrieve_expense_rule_params params
    rule = policy.expense_rules.create!(rule_params)
    if rule.save
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def remove_expense_rule(rule_id, policy_id)
    policy = retrieve_policy policy_id
    rule = policy.expense_rules.where(id: rule_id)
    if rule.destroy
      return true
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def add_budget_rule(params)
    # retrieving policies from the policy retrieval service
    policy = retrieve_policy params[:policy_id]
    rule_params = retrieve_budget_rule_params params
    rule = policy.budget_rules.create!(rule_params)
    if rule.save
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def edit_expense_rule(params)
    rule_params = retrieve_expense_rule_params params
    rule = load_expense_rule params
    if rule.update(rule_params)
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def edit_budget_rule(params)
    rule_params = retrieve_expense_rule_params params
    rule = load_budget_rule params
    if rule.update(rule_params)
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  private

  def retrieve_expense_rule_params(params = {})
    return if params.blank?
    params.require(:expense_rule)
  end

  def retrieve_budget_rule_params(params = {})
    return if params.blank?
    params.require(:budget_rule)
  end

  def load_expense_rule(params = {})
    return if params.blank?
    rule = retrieve_policy(params[:policy_id]).expense_rules.where(id: params[:expense_rule_id])
  end

  def load_budget_rule(params = {})
    return if params.blank?
    rule = retrieve_policy(params[:policy_id]).budget_rules.where(id: params[:budget_rule_id])
  end

  def retrieve_policy(policy_id)
    PolicyRetrievalService.list(@user, view: 'admin').where(id: policy_id)
  end

end