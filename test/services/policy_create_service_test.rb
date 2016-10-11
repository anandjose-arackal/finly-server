require 'test_helper'

class PolicyCreateServiceTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @policy = @company.policies.non_default.first
    @admin = User.find_by(email: 'admin@finlytest.io')
    @user = User.find_by(email: 'user0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @manager4 = User.find_by(email: 'manager4@finlytest.io')
  end

  test 'creating a new policy should clone the existing company policy' do
    # Policy cannot be created unless name is provided
    policy_create_service = PolicyCreateService.new
    assert_not policy_create_service.create_policy(@company,@admin, nil)
    assert policy_create_service.errors.present?

    # Successfully created a new policy by cloning companies default policy
    new_policy = policy_create_service.create_policy(@company,@admin, 'Test')
    assert new_policy.present? and new_policy.valid?
    assert policy_create_service.errors.blank?
    assert_not new_policy.default
    assert @company.policies.default.user_team_mapping.count, new_policy.user_team_mapping.count

    # Company cannot have two policies with the same names
    assert_not policy_create_service.create_policy @company,@admin, 'Test'
    assert policy_create_service.errors.present?
  end

  test 'cloning a policy' do
    # Clone a policy and check if configuration is cloned along with user mapping
    assert @policy.configuration.require_category
    policy_create_service = PolicyCreateService.new
    policy = policy_create_service.clone_policy @policy, 'New Policy', user: true
    assert policy.configuration.require_category
    assert UserTeamService.new(@user).manager(policy_id: policy.id).id, @manager4.id
    assert UserTeamService.new(@user).manager.id, @manager.id

    # Cloning a policy without user mapping
    policy = policy_create_service.clone_policy @policy, 'New Policy - 2'
    assert UserTeamService.new(@user).manager(policy_id: policy.id).blank?
    assert UserTeamService.new(@user).manager.id, @manager.id
  end

end
