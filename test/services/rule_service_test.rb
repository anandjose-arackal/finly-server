require 'test_helper'

class RuleServiceTest < ActiveSupport::TestCase

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
                                        period_id: 1}
                          }

    @modified_budget_rule_params = {budget_rule: {amount: 120,
                                                 currency_id: 1,
                                                 policy_id: 3,
                                                 category_id: 1,
                                                 rule_type_id: 1,
                                                 period_id: 2}
                                   }

    @rsadmin = RuleService.new(@admin, @policy.id)
    @rsemp = RuleService.new(@employee, @policy.id)

  end

  test "should create and edit a new expense rule" do

    assert_difference '@policy.expense_rules_count', 1 do
      @rule = @rsadmin.add_expense_rule @expense_rule_params
      assert_equal "Test category", @rule.category_name, "Mismatch in category name."
      assert_equal 100, @rule.amount_value
      assert_equal 30, @rule.days_after
    end

    # editing the expense rule
    edited_rule = @rsadmin.edit_expense_rule(@modified_expense_rule_params, @rule.id)
    assert_equal 120, edited_rule.amount_value
    assert_equal 20, edited_rule.days_after

  end

  test "should create and edit a new budget rule" do

    assert_difference '@policy.budget_rules_count', 1 do
      @rule = @rsadmin.add_budget_rule @budget_rule_params
      assert_equal "Test category", @rule.category_name, "Mismatch in category name."
      assert_equal 100, @rule.amount_value
      assert_equal "Day", @rule.period, "Budget period mismatch"
    end

    # editing budget rule
    edited_rule = @rsadmin.edit_budget_rule(@modified_budget_rule_params, @rule.id)
    assert_equal 120, edited_rule.amount_value
    assert_equal "Week", edited_rule.period

  end


  test "should delete an existing expense rule from policy" do
    assert_difference '@policy.expense_rules_count', -1 do
      assert @rsadmin.remove_expense_rule(@sample_expense_rule.id, @policy.id)
      assert_not ExpenseRule.exists?(@sample_expense_rule.id)
    end
  end

  test "should delete an existing budget rule from policy" do
    assert_difference '@policy.budget_rules_count', -1 do
      assert @rsadmin.remove_budget_rule(@sample_budget_rule.id, @policy.id)
      assert_not BudgetRule.exists?(@sample_budget_rule.id)
    end
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