# action to create a new rule in a policy
# params:

# policy_id: id of the policy to which rules are to be added
# rule:
  # rule_id: id of the rule that needs to be destroyed
  # expense_rule: set to true of it's an expense rule
  # budget_rule: set to true if it's a budget rule

class Policy::Rule::Destroy < Policy::Rule::Base

  def init
    super()
    self.rule_params = rule_parameters
    self.rule = policy.budget_rules.find_by(id: rule_params[:rule_id]) if rule_params[:budget_rule]
    self.rule = policy.expense_rules.find_by(id: rule_params[:rule_id]) if rule_params[:expense_rule]
  end

  def validate
    unless rule
      errors << "Rule not found."
      return false
    end
  end

  def process
    unless rule.destroy
      errors << rule.errors.full_messages
    end
  end

  def post_process
    # nothing
  end

end