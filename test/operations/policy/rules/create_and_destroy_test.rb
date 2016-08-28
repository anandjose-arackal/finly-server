require 'test_helper'
require 'helpers/report_operation_test_helper'

class CreateAndDestroyTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.find_by(email: 'admin@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @employee = User.find_by(email: 'user0@finlytest.io')
    @policy = Policy.find_by(id: 3)
    @sample_expense_rule = @policy.expense_rules.first
    @sample_budget_rule = @policy.budget_rules.first
    @expense_rule_params = {expense_rule: {amount: 100,
                                           currency_id: 1,
                                           category_id: 1,
                                           days_after: 30,
                                           expense_rule_type_id: 1,
                                           rule_type_id: 1,
                                           policy_id: 3}
                            }
    @modified_expense_rule_params = {expense_rule: {amount: 120,
                                                    currency_id: 1,
                                                    category_id: 1,
                                                    days_after: 20,
                                                    expense_rule_type_id: 1,
                                                    rule_type_id: 1,
                                                    policy_id: 3}
                                    }

    @budget_rule_params = {budget_rule: {amount: 100,
                                         currency_id: 1,
                                         policy_id: 3,
                                         category_id: 1,
                                         rule_type_id: 1,
                                         budget_period_id: 1}
                           }

    @modified_budget_rule_params = {budget_rule: {amount: 120,
                                                  currency_id: 1,
                                                  policy_id: 3,
                                                  category_id: 1,
                                                  rule_type_id: 1,
                                                  budget_period_id: 2}
                                    }

  end

  test "admins can add expense and budget rules to the policy" do

  end
end