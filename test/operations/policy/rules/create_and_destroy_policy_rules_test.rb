require 'test_helper'

class CreateAndDestroyPolicyRulesTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = users(:admin)
    @manager = users(:manager)
    @employee = users(:employee)
    @policy = Policy.non_default.second
    @sample_expense_rule = @policy.expense_rules.first
    @sample_budget_rule = @policy.budget_rules.first
    @expense_rule_params = { expense_rule: { greater_than_amount_attributes: {value: 110, currency_id: 1},
                                             category_id: 1,
                                             days_after: 30,
                                             expense_rule_type_id: 1,
                                             rule_type_id: 1
                                          },
                             policy_id: @policy.id,
                             view: 'admin'
                           }

    @budget_rule_params = { budget_rule: {amount_attributes: {value: 110, currency_id: 1},
                                          category_id: 1,
                                          rule_type_id: 1,
                                          period_id: 1
                                         },
                            policy_id: @policy.id,
                            view: 'admin'
                          }
  end

  test "company admins can add expense and budget rules to the policy" do
    # mocking the return value of the index presenter in policies
    index_presenter = Policy::Index::IndexPresenter.new(@admin, {policies: Policy.where(id: @policy.id)})
    Policy::Index.stubs(:call).returns(index_presenter)

    # adding expense rules to the policy
    create_op = Policy::Rules::Create.new(@admin, @expense_rule_params)
    assert_difference '@policy.expense_rules.count', 1 do
      @result = create_op.run
    end
    assert @result.success?
    assert_equal 110, @result.rule.greater_than_amount_value
    assert_equal 30, @result.rule.days_after
    assert_equal 1, @result.rule.expense_rule_type_id
    assert_equal 1, @result.rule.category_id

    # adding budget rules to the policy
    create_op = Policy::Rules::Create.new(@admin, @budget_rule_params)
    assert_difference '@policy.budget_rules.count', 1 do
      @result = create_op.run
    end
    assert_equal 110, @result.rule.amount_value
    assert_equal 1, @result.rule.period_id
    assert_equal 1, @result.rule.category_id
    assert_equal 1, @result.rule.rule_type_id
  end

  test "policy admins can create rules within the policy" do
    # mocking the return value of the index presenter in policies
    index_presenter = Policy::Index::IndexPresenter.new(@manager, {policies: Policy.where(id: @policy.id)})
    Policy::Index.stubs(:call).returns(index_presenter)

    # making the manager a policy admin temporarily
    @manager.stubs(:policy_admin?).returns(true)
    @manager.stubs(:policy_admin?).with(@policy).returns(true)

    # adding expense rules to the policy
    create_op = Policy::Rules::Create.new(@manager, @expense_rule_params)
    assert_difference '@policy.expense_rules.count', 1 do
      @result = create_op.run
    end
    assert @result.success?
    assert_equal 110, @result.rule.greater_than_amount_value
    assert_equal 30, @result.rule.days_after
    assert_equal 1, @result.rule.expense_rule_type_id
    assert_equal 1, @result.rule.category_id

    # adding budget rules to the policy
    create_op = Policy::Rules::Create.new(@manager, @budget_rule_params)
    assert_difference '@policy.budget_rules.count', 1 do
      @result = create_op.run
    end
    assert_equal 110, @result.rule.amount_value
    assert_equal 1, @result.rule.period_id
    assert_equal 1, @result.rule.category_id
    assert_equal 1, @result.rule.rule_type_id
  end


  test "non admins and other motherfuckers can't create rules in the policy" do
    # trying to add expense rule by non admin
    create_op = Policy::Rules::Create.new(@manager, @expense_rule_params)
    assert_no_difference '@policy.expense_rules.count' do
      begin
        @rule = create_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued

    # trying to add a budget rule by non admin
    create_op = Policy::Rules::Create.new(@manager, @budget_rule_params)
    assert_no_difference '@policy.budget_rules.count' do
      begin
        @rule = create_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end

  test "company admins can destroy a rule within a policy" do
    destroy_op = Policy::Rules::Destroy.new(@admin, {policy_id: @policy.id, expense_rule_id: @sample_expense_rule.id})
    assert_difference '@policy.expense_rules.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not ExpenseRule.exists?(@sample_expense_rule.id)

    # deleting a budget rule from the policy
    destroy_op = Policy::Rules::Destroy.new(@admin, {policy_id: @policy.id, budget_rule_id: @sample_budget_rule.id})
    assert_difference '@policy.budget_rules.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not BudgetRule.exists?(@sample_budget_rule.id)
  end

  test "policy admins can destroy rules within a policy" do
    # mocking the return value of the index presenter in policies
    index_presenter = Policy::Index::IndexPresenter.new(@manager, {policies: Policy.where(id: @policy.id)})
    Policy::Index.stubs(:call).returns(index_presenter)

    # making the manager a policy admin temporarily
    @manager.stubs(:policy_admin?).returns(true)
    @manager.stubs(:policy_admin?).with(@policy).returns(true)

    destroy_op = Policy::Rules::Destroy.new(@admin, {policy_id: @policy.id, expense_rule_id: @sample_expense_rule.id})
    assert_difference '@policy.expense_rules.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not ExpenseRule.exists?(@sample_expense_rule.id)

    # deleting a budget rule from the policy
    destroy_op = Policy::Rules::Destroy.new(@admin, {policy_id: @policy.id, budget_rule_id: @sample_budget_rule.id})
    assert_difference '@policy.budget_rules.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not BudgetRule.exists?(@sample_expense_rule.id)
  end

  test "non admins and other motherfuckers cannot destroy a rule within a policy" do
    # trying to destroy an expense rule
    destroy_op = Policy::Rules::Destroy.new(@manager, {policy_id: @policy.id, expense_rule_id: @sample_expense_rule.id})
    assert_no_difference '@policy.expense_rules.count' do
      begin
        @result = destroy_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued

    # trying to delete a budget rule from the policy
    destroy_op = Policy::Rules::Destroy.new(@manager, {policy_id: @policy.id, budget_rule_id: @sample_budget_rule.id})
    assert_no_difference '@policy.budget_rules.count' do
      begin
        @result = destroy_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued

  end

end