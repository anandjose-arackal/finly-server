require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = User.find_by(email: 'finance1@finlytest.io')
    @policy = Policy::Create.new(@admin, name: "Testing...").run
    @policy = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @manager.id, admin: true}).run
  end

  test "admins and policy admins can destroy a policy" do
    assert @policy
    assert @policy.users.count > 0
    destroy_op = Policy::Destroy.new(@admin, policy_id: @policy.id)
    assert_difference 'Policy.count', -1 do
      @result = destroy_op.run
    end
    assert @result
    assert_not Policy.exists?(@policy.id)
  end

  test "policy admins can also destroy a policy" do
    destroy_op = Policy::Destroy.new(@manager, policy_id: @policy.id)
    assert_difference 'Policy.count', -1 do
      @result = destroy_op.run
    end
    assert @result
    assert_not Policy.exists?(@policy.id)
  end

  test "non admins cannot destroy a policy" do
    destroy_op = Policy::Destroy.new(@finance_manager, policy_id: @policy.id)
    assert_no_difference 'Policy.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert Policy.exists?(@policy.id)
  end
end