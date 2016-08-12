class RuleService < BaseService

  def initialize(current_user, policy_id=nil)
    super()
    @user = current_user
    @policy = retrieve_policy policy_id if policy_id
  end

  def add_expense_rule(params)
    # retrieving policies from the policy retrieval service
    rule_params = params
    rule = @policy.expense_rules.create!(rule_params)
    if rule.save
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def remove_expense_rule(rule_id)
    rule = @policy.expense_rules.find_by(id: rule_id)
    if rule && rule.destroy
      return true
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def add_budget_rule(params)
    # retrieving policies from the policy retrieval service
    rule_params = params
    rule = @policy.budget_rules.create!(rule_params)
    if rule.save
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def remove_budget_rule(rule_id)
    rule = @policy.budget_rules.find_by(id: rule_id)
    if rule && rule.destroy
      return true
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def edit_expense_rule(params, rule_id)
    rule_params = params
    rule = load_expense_rule rule_id
    if rule.update(rule_params)
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  def edit_budget_rule(params, rule_id)
    rule_params = params
    rule = load_budget_rule rule_id
    if rule.update(rule_params)
      return rule
    else
      errors << rule.errors.full_messages
      return false
    end
  end

  private

  # def retrieve_expense_rule_params(params = {})
  #   return if params.blank?
  #   # expense_rule_params = params[:expense_rule].except(:amount, :currency_id)
  #   # expense_rule_params[:greater_than_amount_attributes] = {value: params[:expense_rule][:amount], currency_id: params[:expense_rule][:currency_id]}
  #   # expense_rule_params
  #   params
  # end
  #
  # def retrieve_budget_rule_params(params = {})
  #   return if params.blank?
  #   # budget_rule_params = params[:budget_rule].except(:amount, :currency_id)
  #   # budget_rule_params[:amount_attributes] = {value: params[:budget_rule][:amount], currency_id: params[:budget_rule][:currency_id]}
  #   # budget_rule_params
  #   params
  # end

  def load_expense_rule(rule_id)
    return if rule_id.blank?
    rule = retrieve_policy(@policy.id).expense_rules.find_by(id: rule_id)
  end

  def load_budget_rule(rule_id)
    return if rule_id.blank?
    rule = retrieve_policy(@policy.id).budget_rules.find_by(id: rule_id)
  end

  def retrieve_policy(policy_id)
    PolicyRetrievalService.new(@user).list(view: 'admin').where(id: policy_id).first
  end

end