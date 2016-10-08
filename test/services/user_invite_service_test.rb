require 'test_helper'

require 'helpers/report_service_test_helper'
class UserInviteServiceTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by email: 'manager0@finlytest.io'
    @finance_manager = User.find_by email: 'finance0@finlytest.io'
    @employee = User.find_by email: 'user0@finlytest.io'
  end

  test 'user invite flow' do
    # Successful invite
    uis = UserInviteService.new(@manager)
    assert_difference 'User.count', 1 do
      assert uis.invite(company_id: @manager.company_id, email: 'user99@finlytest.io',
                        role_mapping_attributes: [{user_role_id: 4}],
                        team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    assert uis.errors.blank?

    # Employee cannot invite other users
    uis = UserInviteService.new(@employee)
    assert_no_difference 'User.count' do
      assert_not uis.invite(company_id: @employee.company_id, email: 'user100@finlytest.io',
                            role_mapping_attributes: [{user_role_id: 4}],
                            team_mapping_attributes: [{default: true, manager_id: @manager.id,
                                                       finance_manager_id: @finance_manager.id}])
    end
    assert uis.errors.present?

    # Manager/Finance managers can only invite users under them
    # Manager
    uis = UserInviteService.new(@manager)
    assert_no_difference 'User.count' do
      assert_not uis.invite(company_id: @employee.company_id, email: 'user101@finlytest.io',
                            role_mapping_attributes: [{user_role_id: 4}],
                            team_mapping_attributes: [{default: true, manager_id: @admin.id,
                                                       finance_manager_id: @finance_manager.id}])
    end
    assert uis.errors.present?

    # Finance
    uis = UserInviteService.new(@finance_manager)
    assert_no_difference 'User.count' do
      assert_not uis.invite(company_id: @employee.company_id, email: 'user102@finlytest.io',
                            role_mapping_attributes: [{user_role_id: 4}],
                            team_mapping_attributes: [{default: true, manager_id: @manager.id,
                                                       finance_manager_id: @admin.id}])
    end
    assert uis.errors.present?

    # Manager/Finance managers can only invite users as employee/(manager or finance manager)
    uis = UserInviteService.new(@manager)
    assert_no_difference 'User.count' do
      assert_not uis.invite(company_id: @manager.company_id, email: 'user103@finlytest.io', role_mapping_attributes: [{user_role_id: UserRole.employee_id},
                                                                                                                      {user_role_id: UserRole.admin_id}],
                            team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    assert uis.errors.present?

    uis = UserInviteService.new(@finance_manager)
    assert_no_difference 'User.count' do
      assert_not uis.invite(company_id: @manager.company_id, email: 'user103@finlytest.io', role_mapping_attributes: [{user_role_id: UserRole.employee_id},
                                                                                                                      {user_role_id: UserRole.admin_id}],
                            team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    assert uis.errors.present?

    # Only admins can invite other admins
    # Admins can invite users without manager/finance manager
    uis = UserInviteService.new(@admin)
    assert_difference 'User.count', 1 do
      assert uis.invite(company_id: @admin.company_id, email: 'user104@finlytest.io', role_mapping_attributes: [{user_role_id: UserRole.admin_id}])
    end
    assert uis.errors.blank?
  end

  test 'user resend invite flow' do
    uis = UserInviteService.new(@manager)
    assert_difference 'User.count', 1 do
      assert uis.invite(company_id: @manager.company_id, email: 'user120@finlytest.io',
                        role_mapping_attributes: [{user_role_id: 4}],
                        team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    assert_no_difference 'User.count' do
      assert_not uis.invite(company_id: @manager.company_id, email: 'user120@finlytest.io',
                            role_mapping_attributes: [{user_role_id: 4}],
                            team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    assert_no_difference 'User.count' do
      assert uis.resend_invite('user120@finlytest.io')
    end
    user = User.find_by_email('user120@finlytest.io')
    assert user.roles.count == 1
    assert user.team_mapping.count == 1
    assert UserTeamService.new(user).manager, @manager.id
  end

  test 'destroy invite flow' do
    uis = UserInviteService.new(@manager)
    assert_difference 'User.count', 1 do
      assert uis.invite(company_id: @manager.company_id, email: 'user110@finlytest.io',
                        role_mapping_attributes: [{user_role_id: 4}],
                        team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    user = User.find_by_email('user110@finlytest.io')
    assert_difference 'User.count', -1 do
      assert UserInviteService.new(@manager).destroy_invite(user.id)
    end
    assert User.find_by_email('user110@finlytest.io').blank?

    # Only inviting users/admins can destroy invites
    uis = UserInviteService.new(@manager)
    assert_difference 'User.count', 1 do
      assert uis.invite(company_id: @manager.company_id, email: 'user111@finlytest.io',
                        role_mapping_attributes: [{user_role_id: 4}],
                        team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    end
    user = User.find_by_email('user111@finlytest.io')
    assert_no_difference 'User.count' do
      assert_not UserInviteService.new(@finance_manager).destroy_invite(user.id)
    end
    assert User.find_by_email('user111@finlytest.io').present?

    assert_difference 'User.count', -1 do
      assert UserInviteService.new(@admin).destroy_invite(user.id)
    end
    assert User.find_by_email('user111@finlytest.io').blank?

    # Invites can only be destroyed before joining
  end

  test 'update invite flow do' do

  end

  test 'accept invite flow do' do
    # Successful accept
    u = User.new(company_id: @manager.company_id, email: 'user110@finlytest.io',
                 role_mapping_attributes: [{user_role_id: 4}],
                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    u.invite! do |u|
      u.skip_invitation = true
    end
    token = u.raw_invitation_token
    uis = UserInviteService.new
    name = 'test name'
    password = 'password'
    mobile_number = '9986676713'
    assert uis.accept_invitation(invitation_token: token, name: name, password: password, mobile_number: mobile_number)
    u = User.invitation_accepted.find_by_email('user110@finlytest.io')
    assert u.present?
    assert_equal u.mobile_number, mobile_number
    assert_equal u.name, name

    # invitation token, name, mobile number and password is required to accept invites
    u = User.new(company_id: @manager.company_id, email: 'user111@finlytest.io',
                 role_mapping_attributes: [{user_role_id: 4}],
                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}])
    u.invite! do |u|
      u.skip_invitation = true
    end
    token = u.raw_invitation_token
    uis = UserInviteService.new
    name = 'test name'
    password = 'password'
    mobile_number = '9986676713'
    assert_not uis.accept_invitation(invitation_token: token, name: nil, password: password, mobile_number: mobile_number)
    u = User.invitation_accepted.find_by_email('user111@finlytest.io')
    assert u.blank?

    assert_not uis.accept_invitation(invitation_token: token, name: name, password: password, mobile_number: nil)
    u = User.invitation_accepted.find_by_email('user111@finlytest.io')
    assert u.blank?

    assert_not uis.accept_invitation(invitation_token: token, name: name, password: nil, mobile_number: mobile_number)
    u = User.invitation_accepted.find_by_email('user111@finlytest.io')
    assert u.blank?

    assert uis.accept_invitation(invitation_token: token, name: name, password: password, mobile_number: mobile_number)
    u = User.invitation_accepted.find_by_email('user111@finlytest.io')
    assert u.present?
  end

end
