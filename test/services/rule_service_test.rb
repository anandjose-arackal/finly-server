require 'test_helper'

class RuleServiceTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.find_by(email: 'admin@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @employee = User.find_by(email: 'user0@finlytest.io')
    @policy = Policy.find_by(id: 3)
    @expense_rule_params = {expense_rule: {amount: 100,
                                           currency_id: 1,
                                           category_id: 1,
                                           days_after: 30,
                                           expense_rule_type_id: 1,
                                           rule_type_id: 1,
                                           policy_id: 3}
                           }
    @modified_expense_rule_params = {expense_rule: {amount: 100,
                                                    currency_id: 1,
                                                    category_id: 1,
                                                    days_after: 30,
                                                    expense_rule_type_id: 1,
                                                    rule_type_id: 1,
                                                    policy_id: 3}
                                    }

    @budget_rule_params = {budet_rule: {amount: 100,
                                        currency_id: 1,
                                        policy_id: 3,
                                        category_id: 1,
                                        rule_type_id: 1,
                                        budget_period_id: 1}
                          }

    @modified_budget_rule_params = {budet_rule: {amount: 100,
                                                 currency_id: 1,
                                                 policy_id: 3,
                                                 category_id: 1,
                                                 rule_type_id: 1,
                                                 budget_period_id: 1}
                                   }

    @rsadmin = RuleService.new(@admin)
    @rsemp = RuleService.new(@employee)

  end

  test "should create and edit a new expense rule" do

    assert_difference '@policy.expense_rules_count', 1 do
      rule = @rsadmin.add_expense_rule @expense_rule_params
      assert_equal "Test category", rule.category_name, "Mismatch in category name."
      assert_equal 100, rule.amount_value
    end

  end

  test "should create and edit a new budget rule" do

  end

  test "should delete and existing expense rule from policy" do

  end

  test "should delete an existing budget rule from policy" do

  end

  # todo - once the checks for admin has been placed inside the service
  # test "non admins cannot create rules for a policy" do
  #
  #   assert_difference '@policy.expense_rules_count', 1 do
  #     rule = @rsemployee.add_expense_rule @expense_rule_params
  #     assert_equal "Test category", rule.category_name, "Mismatch in category name."
  #     assert_equal 100, rule.amount_value
  #   end
  #
  # end
end