require 'test_helper'
require 'helpers/report_operation_test_helper'

class CreatePolicyTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
  end

  test "successfully creating a policy by an admin" do
    create_op = Policy::Create.new(@admin, name: "Test")
    assert_difference 'Policy.count', 1 do
      @result = create_op.run
    end
    # the create operation returns a list of policies from the company
    policy = @result.policies.order(created_at: :desc).first
    assert @result.success?
    assert policy
    assert_equal "Test", policy.name
    assert_equal @admin.id, policy.admins.first.id
    assert_equal 1, policy.users.count
  end

  test "non-admins cannot create a policy within a company" do
    create_op = Policy::Create.new(@manager, name: "Test")
    assert_no_difference 'Policy.count', 1 do
      begin
        @result = create_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued

    # checking finance manager as well
    create_op = Policy::Create.new(@finance_manager, name: "Test")
    assert_no_difference 'Policy.count', 1 do
      begin
        @result = create_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end

  test "creating a policy without a name should fail" do
    create_op = Policy::Create.new(@admin, "")
    assert_no_difference 'Policy.count' do
      @result = create_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
  end
end