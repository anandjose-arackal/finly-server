require 'test_helper'

class UserTeamServiceTest < ActiveSupport::TestCase

  def setup
    @a = User.find_by(email: 'admin@finlytest.io')
    @u = User.find_by(email: 'user0@finlytest.io')
    @m0 = User.find_by(email: 'manager0@finlytest.io')
    @m1 = User.find_by(email: 'manager1@finlytest.io')
    @m2 = User.find_by(email: 'manager2@finlytest.io')
    @m3 = User.find_by(email: 'manager3@finlytest.io')

    @fm0 = User.find_by(email: 'finance0@finlytest.io')
    @fm1 = User.find_by(email: 'finance1@finlytest.io')
    @fm2 = User.find_by(email: 'finance2@finlytest.io')
    @fm3 = User.find_by(email: 'finance3@finlytest.io')
  end

  test 'employee team view' do
    # Employee team view should return nil
    team_service = UserTeamService.new(@u)
    assert team_service.team(UserRole.employee_id).blank?

    # Employee manager team view should return nil
    assert team_service.team(UserRole.manager_id).blank?

    # Employee finance team view should return nil
    assert team_service.team(UserRole.finance_manager_id).blank?

    # Employee admin team view should return nil
    assert team_service.team(UserRole.admin_id).blank?
  end

  test 'manager team view' do
    team_service = UserTeamService.new(@m0)

    # When no view is provided, returns nil
    team = team_service.team(nil)
    assert team.blank?

    # Manager team view should not return nil
    team = team_service.team(UserRole.manager_id)
    assert_not team.blank?

    # Manager finance team view should return nil
    assert team_service.team(UserRole.finance_manager_id).blank?

    # Manager admin team view should return nil
    assert team_service.team(UserRole.admin_id).blank?
  end

  test 'finance team view' do
    team_service = UserTeamService.new(@fm0)

    # When no view is provided, returns nil
    team = team_service.team(nil)
    assert team.blank?

    # Finance manager team view should return nil
    assert team_service.team(UserRole.manager_id).blank?

    # Finance team view should not return nil
    team = team_service.team(UserRole.finance_manager_id)
    assert_not team.blank?

    # Finance admin team view should return nil
    assert team_service.team(UserRole.admin_id).blank?
  end

  test 'retrieving manager' do
    # When manager is not set
    team_service = UserTeamService.new(@m3)
    assert team_service.manager.blank?
    assert team_service.manager(amount: 500).blank?

    # When manager is set
    team_service = UserTeamService.new(@u)
    assert_equal team_service.manager.id, @m0.id
    assert_equal team_service.manager(amount: 1000, currency_id: Currency.first).id, @m3.id
  end

  test 'retrieving finance manager' do
    # When manager is not set
    team_service = UserTeamService.new(@m3)
    assert team_service.finance_manager.blank?
    assert team_service.finance_manager(amount: 2500).blank?

    # When manager is set
    team_service = UserTeamService.new(@u)
    assert_equal team_service.finance_manager.id, @fm0.id
    assert_equal team_service.finance_manager(amount: 2000, currency_id: Currency.first).id, @fm3.id
  end

  test 'retrieving approves to' do
    # When approves to is not set
    team_service = UserTeamService.new(@m3)
    assert team_service.approves_to.blank?
    assert team_service.approves_to(amount: 2500).blank?

    # When approves to is set
    team_service = UserTeamService.new(@m0)
    assert_equal team_service.approves_to.id, @m1.id
    assert_equal team_service.approves_to(amount: 1000, currency_id: Currency.first).id, @m2.id
  end

  test 'retrieving approves finance to' do
    # When approves finance to is not set
    team_service = UserTeamService.new @m3
    assert team_service.approves_to.blank?
    assert team_service.approves_to(amount: 2500).blank?

    # When approves finance to is set
    team_service = UserTeamService.new @fm0
    assert_equal team_service.approves_finance_to.id, @fm1.id
    assert_equal team_service.approves_finance_to(amount: 2000, currency_id: Currency.first).id, @fm2.id
  end



end
