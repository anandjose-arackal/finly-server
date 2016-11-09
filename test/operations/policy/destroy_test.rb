require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = User.find_by(email: 'finance1@finlytest.io')
    @policy = Policy::Create.(@admin, name: "Testing...").policies.order(created_at: :desc).first
    # @policy = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @manager.id, admin: true}).run
  end

  test "company admins can destroy a policy" do
    assert @policy
    assert @policy.users.count > 0
    destroy_op = Policy::Destroy.new(@admin, policy_id: @policy.id)
    assert_difference 'Policy.not_deleted.count', -1 do
      @result = destroy_op.run
      @policy.reload
    end
    assert @result.success?
    assert @policy.is_deleted
  end

  test "policy admins can also destroy a policy" do
    # mocking the return value of the index presenter in policies
    index_presenter = Policy::Index::IndexPresenter.new(@manager, {policies: Policy.where(id: @policy.id)})
    # mocking the user as a policy admin
    @manager.stubs(:policy_admin?).returns(true)
    Policy::Index.stubs(:call).returns(index_presenter)

    destroy_op = Policy::Destroy.new(@manager, policy_id: @policy.id)
    assert_difference 'Policy.not_deleted.count', -1 do
      @result = destroy_op.run
      @policy.reload
    end
    assert @result
    assert @policy.is_deleted
  end

  test "non admins cannot destroy a policy" do
    # finance manager trying to delete a policy
    destroy_op = Policy::Destroy.new(@finance_manager, policy_id: @policy.id)
    assert_no_difference 'Policy.not_deleted.count' do
      begin
        @result = destroy_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.is_deleted

    # manager trying to destroy a policy
    destroy_op = Policy::Destroy.new(@manager, policy_id: @policy.id)
    assert_no_difference 'Policy.not_deleted.count' do
      begin
        @result = destroy_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
    assert_not @policy.is_deleted

  end
end