require 'test_helper'

class PolicyUserServiceTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @policy = @company.policies.non_default.first
    @user = User.find_by(email: 'user0@finlytest.io')
    @user1 = User.find_by(email: 'user1@finlytest.io')
    @user2 = User.find_by(email: 'user2@finlytest.io')
    @user3 = User.find_by(email: 'user3@finlytest.io')
    @user4 = User.find_by(email: 'user4@finlytest.io')
    @policy_user_service = PolicyUserService.new(@policy)
  end

  test 'add user test' do
    team_service = UserTeamService.new(@user2)

    # Cannot pass null while adding user
    pre_count = team_service.mappings(policy_id: @policy.id).count
    assert_not @policy_user_service.add_user(nil)
    assert @policy_user_service.errors.present?
    assert_equal team_service.mappings(policy_id: @policy.id).count, pre_count

    # Adding user should create a mapping and user_team_mapping
    # Adding user without specifing role should add the user as an employee
    pre_count = team_service.mappings(policy_id: @policy.id).count
    assert @policy.users.find_by(id: @user2.id).blank?
    assert team_service.mappings(policy_id: @policy.id).blank?
    assert @policy_user_service.add_user(@user2)
    assert_equal @user2.role_mapping.policy(@policy.id).count, 1
    assert @policy.users.by_user(@user2.id).present?
    assert team_service.mappings(policy_id: @policy.id).present?
    assert_equal @user2.role_mapping.policy(@policy.id).count, 1
    assert @user2.employee?(@policy)
    assert_not @user2.manager?(@policy)
    assert_not @user2.manager?(@policy)
    assert_not @user2.admin?(@policy)
    assert_not @user2.auditor?(@policy)
    assert_equal team_service.mappings(policy_id: @policy.id).count, (pre_count+1)

    # Adding user by specifying role should assign the specific role to the user
    assert_not @user3.admin?
    assert @policy_user_service.add_user(@user3, UserRole.admin_id)
    assert_equal @user3.role_mapping.policy(@policy.id).count, 1
    assert @user3.admin?(@policy)
    assert_not @user3.finance_manager?(@policy)
    assert_not @user3.manager?(@policy)
    assert_not @user3.employee?(@policy)
    assert_not @user3.auditor?(@policy)

    # Can assign a user multiple roles in a policy
    assert_not @user4.admin?
    assert_not @user4.manager?
    assert @policy_user_service.add_user(@user4, [UserRole.admin_id, UserRole.manager_id])
    assert_equal @user4.role_mapping.policy(@policy.id).count, 2
    assert @user4.admin?(@policy)
    assert_not @user4.finance_manager?(@policy)
    assert @user4.manager?(@policy)
    assert_not @user4.employee?(@policy)
    assert_not @user4.auditor?(@policy)

    # Cannot add already added users
    pre_count = team_service.mappings(policy_id: @policy.id).count
    assert_not @policy_user_service.add_user(@user2)
    assert @policy_user_service.errors.present?
    assert_equal team_service.mappings(policy_id: @policy.id).count, pre_count
  end

  test 'remove user' do
    # Cannot remove a user not present in a policy
    assert @policy.users.find_by(id: @user3.id).blank?
    assert_not @policy_user_service.remove_user(@user3)
    assert @policy_user_service.errors.present?

    # A user must be passed while removing the user
    assert_not @policy_user_service.remove_user(nil)
    assert @policy_user_service.errors.present?

    # Removing a user should remove the user from the policy
    assert @policy_user_service.add_user(@user3)
    assert @policy.users.find_by(id: @user3.id).present?
    assert @policy_user_service.remove_user(@user3)
    assert_not @policy.users.find_by(id: @user3.id).present?

    # Removing a user shold remove user configuration
    assert @policy_user_service.add_user(@user3)
    assert @user3.team_mapping.policy(@policy.id).count > 0
    assert @policy_user_service.remove_user(@user3)
    assert @user3.team_mapping.policy(@policy.id).blank?

    # Removing a user shold remove associated user roles
    assert @policy_user_service.add_user(@user3)
    assert @user3.role_mapping.policy(@policy.id).count > 0
    assert @policy_user_service.remove_user(@user3)
    assert @user3.role_mapping.policy(@policy.id).blank?
  end

end
