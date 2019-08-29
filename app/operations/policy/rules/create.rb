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
#     budget_rule_field_mappings_attributes: [
#       field_configuration_id
#       field_drop_down_item_id
#     ]
#
# budget_rule:
#     amount: the budget amount
#     currency_id:
#     category_id: if it's a category specific budget
#     rule_type_id: blocking or warning
#     period_id: the id based on the period of the budget - day, week, month, year
#     budget_rule_field_mappings_attributes: [
#       field_configuration_id
#       field_drop_down_item_id
#     ]
#

class Policy::Rules::Create < Policy::Rules::Base

  def init
    op = Policy::Index.(user, params)
    self.policy = op.policies.find_by(id: (params[:policy_id] or params[:id]))
    self.rule_params = rule_parameters
  end

  def validate
    super()
    if rule_params.blank?
      messages[:error] << "Rule attributes not provided"
      return false
    end
  end

  def pre_process
    if params[:expense_rule] && rule_params[:greater_than_amount_attributes][:value] == ""
      rule_params[:greater_than_amount_attributes][:value] = 0
    end

    # choosing the currency for the rule based on the currency of the respective policy
    # for budget rule
    if rule_params[:amount_attributes].present?
      rule_params[:amount_attributes][:currency_id] = self.policy.base_currency_id
    end

    if rule_params[:with_receipt_amount_attributes].present?
      rule_params[:with_receipt_amount_attributes][:currency_id] = self.policy.base_currency_id
    end

    if rule_params[:without_receipt_amount_attributes].present?
      rule_params[:without_receipt_amount_attributes][:currency_id] = self.policy.base_currency_id
    end

    # for expense rule
    if rule_params[:greater_than_amount_attributes].present?
      rule_params[:greater_than_amount_attributes][:currency_id] = self.policy.base_currency_id
    end
  end

  def process
    if params[:expense_rule]
      if params.dig(:expense_rule, :expense_rule_category_mappings_attributes)
        category_ids = params[:expense_rule][:expense_rule_category_mappings_attributes].pluck :category_id
        category_ids.each do |category_id|
          rule_params[:category_id] = category_id
          self.rule = self.policy.expense_rules.create(rule_params)
          unless ExpenseRule.exists?(rule.id)
            messages[:error] = rule.errors.full_messages
            return false
          end
        end
      else
        self.rule = self.policy.expense_rules.create(rule_params)
        unless ExpenseRule.exists?(rule.id)
          messages[:error] = rule.errors.full_messages
          return false
        end
      end
    else
      self.rule = self.policy.budget_rules.create(rule_params)
      unless BudgetRule.exists?(rule.id)
        messages[:error] = rule.errors.full_messages
        return false
      end
    end
  end

  def post_process
    # updating the rule amount in all currencies - this will be done in the cron job at the end of the day
    # if rule.is_a?(ExpenseRule) && rule.greater_than_amount.present?
    #   rule.greater_than_amount.update_currencies
    # end
    # if rule.is_a?(BudgetRule) && rule.amount.present?
    #   rule.amount.update_currencies
    # end

    messages[:success] << "Rule added"
  end

end
