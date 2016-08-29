# action to create a new rule in a policy
# params:
# policy_id: id of the policy to which rules are to be added
# expense_rule: set to true of it's an expense rule
# budget_rule: set to true if it's a budget rule
#

class Policy::Rule::Create < Policy::Rule::Create

  def init
    super()
    self.rule_params = rule_parameters
  end

  def validate
    super()
    if rule_parameters.blank?
      errors << "Rule attributes not provided"
      return false
    end
  end

  def process
    if params[:expense_rule]
      self.rule = @policy.expense_rules.create!(rule_params)
      unless rule.save
        errors << rule.errors.full_messages
        return false
      end
    else
      self.rule = @policy.budget_rules.create!(rule_params)
      unless rule.save
        errors << rule.errors.full_messages
        return false
      end
    end
  end


end