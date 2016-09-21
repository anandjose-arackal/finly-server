# action to create a new rule in a policy
# params:

# policy_id: id of the policy to which rules are to be added
# expense_rule_id: id of the expense rule that needs to be destroyed
# budget_rule_id: id of the budget rule that needs to be destroyed

# only one of the above will be passed of course


class Policy::Rules::Destroy < Policy::Rules::Base

  def init
    super()
    self.rule = policy.expense_rules.find_by(id: params[:expense_rule_id]) if params[:expense_rule_id]
    self.rule = policy.budget_rules.find_by(id: params[:budget_rule_id]) if params[:budget_rule_id]
  end

  def validate
    unless rule
      messages[:error] << "Rule not found."
      return false
    end
  end

  def process
    unless rule.destroy
      messages[:error] << rule.errors.full_messages
    end
  end

  def post_process
    messages[:success] << "Rule destroyed."
  end

  def success
    Policy::Rules::Base::RulePresenter.new(user, {result: true, policy: policy}, messages)
  end

end