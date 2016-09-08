require 'test_helper'

class CreateInviteTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @user = User.find_by(email: 'user0@finlytest.io')
    @employee = User.find_by(email: 'user0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @second_manager = User.find_by(email: 'manager1@finlytest.io')
    @third_manager = User.find_by(email: 'manager2@finlytest.io')
    @finance_manager = User.find_by(email: 'finance0@finlytest.io')
    @second_finance_manager = User.find_by(email: 'finance1@finlytest.io')
  end

  test "invite flow test" do
    user_invite_op = User::Invite::Create.new(@manager,{invite: {company_id: @manager.company_id, email: 'user99@finlytest.io',
                                             role_mapping_attributes: [{user_role_id: 4}],
                                             team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_difference 'User.count', 1 do
      @new_user = user_invite_op.run
    end
    assert @new_user
    assert @new_user.employee?
    assert_equal @manager.id, @new_user.invited_by_id
    assert user_invite_op.errors.empty?

    # Employee cannot invite other users
    user_invite_op = User::Invite::Create.new(@employee,{invite: {company_id: @employee.company_id, email: 'user100@finlytest.io',
                                                                 role_mapping_attributes: [{user_role_id: 4}],
                                                                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_no_difference 'User.count' do
      begin
        @new_user = user_invite_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued

    # Manager/Finance managers can only invite users under them

    # Manager
    user_invite_op = User::Invite::Create.new(@manager,{invite: {company_id: @employee.company_id, email: 'user111@finlytest.io',
                                                                  role_mapping_attributes: [{user_role_id: 4}],
                                                                  team_mapping_attributes: [{default: true, manager_id: @admin.id, finance_manager_id: @finance_manager.id}]}})
    assert_no_difference 'User.count' do
      @new_user = user_invite_op.run
    end
    assert_not @new_user
    assert user_invite_op.errors.present?

    # # Finance
    user_invite_op = User::Invite::Create.new(@finance_manager,{invite: {company_id: @employee.company_id, email: 'user999@finlytest.io',
                                                                 role_mapping_attributes: [{user_role_id: 4}],
                                                                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @admin.id}]}})
    assert_no_difference 'User.count' do
      @new_user = user_invite_op.run
    end
    assert_not @new_user
    assert user_invite_op.errors.present?


    # Manager/Finance managers can only invite users as employee/(manager or finance manager)
    # manager
    user_invite_op = User::Invite::Create.new(@manager,{invite: {company_id: @employee.company_id, email: 'user111@finlytest.io',
                                                                 role_mapping_attributes: [{user_role_id: 4}, {user_role_id: 3}, {user_role_id: 1}],
                                                                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_no_difference 'User.count' do
      @new_user = user_invite_op.run
    end
    assert_not @new_user
    assert user_invite_op.errors.present?

    # finance
    user_invite_op = User::Invite::Create.new(@finance_manager,{invite: {company_id: @employee.company_id, email: 'user111@finlytest.io',
                                                                 role_mapping_attributes: [{user_role_id: 4}, {user_role_id: 2}, {user_role_id: 1}],
                                                                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_no_difference 'User.count' do
      @new_user = user_invite_op.run
    end
    assert_not @new_user
    assert user_invite_op.errors.present?

    # Only admins can invite other admins
    # Admins can invite users without manager/finance manager
    user_invite_op = User::Invite::Create.new(@admin,{invite: {company_id: @employee.company_id, email: 'user111@finlytest.io',
                                                                         role_mapping_attributes: [{user_role_id: 4}, {user_role_id: 2}, {user_role_id: 1}],
                                                                         team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_difference 'User.count', 1 do
      @new_user = user_invite_op.run
    end
    assert @new_user
    assert @new_user.admin?
    assert_equal @admin.id, @new_user.invited_by_id
    assert_not user_invite_op.errors.present?
  end
end