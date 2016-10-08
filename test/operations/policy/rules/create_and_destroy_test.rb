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
    @expense_rule_params = { policy_id: @policy.id,
                            expense_rule: {amount: 110,
                                           currency_id: 1,
                                           category_id: 1,
                                           days_after: 30,
                                           expense_rule_type_id: 1,
                                           rule_type_id: 1,
                                           policy_id: @policy.id}
                            }

    @budget_rule_params = { policy_id: @policy.id,
                            budget_rule: {amount: 110,
                                         currency_id: 1,
                                         policy_id: @policy.id,
                                         category_id: 1,
                                         rule_type_id: 1,
                                         budget_period_id: 1}
                           }

  end

  test "admins can add expense and budget rules to the policy" do
    # adding expense rules to the policy
    create_op = Policy::Rules::Create.new(@admin, @expense_rule_params)
    assert_difference '@policy.expense_rules.count', 1 do
      @rule = create_op.run
    end
    assert_equal 110, @rule.greater_than_amount_value
    assert_equal 30, @rule.days_after
    assert_equal 1, @rule.expense_rule_type_id
    assert_equal 1, @rule.category_id

    # adding budget rules to the policy
    create_op = Policy::Rules::Create.new(@admin, @budget_rule_params)
    assert_difference '@policy.budget_rules.count', 1 do
      @rule = create_op.run
    end
    assert_equal 110, @rule.amount_value
    assert_equal 1, @rule.budget_period_id
    assert_equal 1, @rule.category_id
    assert_equal 1, @rule.rule_type_id
  end


  test "non admins and other motherfuckers can't create rules in the policy" do
    # trying to add expense rule by non admin
    create_op = Policy::Rules::Create.new(@manager, @expense_rule_params)
    assert_no_difference '@policy.expense_rules.count' do
      begin
        @rule = create_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued

    # trying to create budget rule
    create_op = Policy::Rules::Create.new(@manager, @budget_rule_params)
    assert_no_difference '@policy.budget_rules.count' do
      begin
        @rule = create_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
  end

  test "only admins can destroy a rule within a policy" do
    destroy_op = Policy::Rules::Destroy.new(@admin, {policy_id: @policy.id, expense_rule_id: @sample_expense_rule.id})
    assert_difference '@policy.expense_rules.count', -1 do
      @result = destroy_op.run
    end
    assert @result

    # deleting a budget rule from the policy
    destroy_op = Policy::Rules::Destroy.new(@admin, {policy_id: @policy.id, budget_rule_id: @sample_budget_rule.id})
    assert_difference '@policy.budget_rules.count', -1 do
      @result = destroy_op.run
    end
    assert @result
  end
end