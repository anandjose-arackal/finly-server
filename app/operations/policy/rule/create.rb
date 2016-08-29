# action to create a new rule in a policy
# params:
# policy_id: id of the policy to which rules are to be added
# expense_rule:
#     amount: greater than amount
#     currency_id
#     category_id : if it's only applicable to a particular category
#     days_after : number of days after which the rule becomes applicable to the expense
#     expense_rule_type_id : require receipt, require note, or disallow
#     rule_type_id: warning or blocking
#
# budget_rule:
#     amount: the budget amount
#     currency_id:
#     category_id: if it's a category specific budget
#     rule_type_id: blocking or warning
#     budget_period_id: the id based on the period of the budget - day, week, month, year
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