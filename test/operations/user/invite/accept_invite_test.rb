require 'test_helper'

class AcceptInviteTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by email: 'manager0@finlytest.io'
    @finance_manager = User.find_by email: 'finance0@finlytest.io'
    @employee = User.find_by email: 'user0@finlytest.io'
  end

  test "successful acceptance of an invite" do
    user_invite_op = User::Invite::Create.new(@manager,{invite: {company_id: @manager.company_id, email: 'user99@finlytest.io',
                                                                 role_mapping_attributes: [{user_role_id: 4}],
                                                                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_difference 'User.count', 1 do
      @new_user = user_invite_op.run
    end
    assert @new_user
    assert @new_user.employee?

    # accepting this invite by the user
    token = @new_user.raw_invitation_token
    name = 'test name'
    password = 'password'
    mobile_number = '9845894295'
    invite_accept_op = User::Invite::Accept.new(invitation_token: token, name: name, mobile_number: mobile_number, password: password)
    @new_user = invite_accept_op.run
    assert @new_user
    assert_equal "test name", @new_user.name
    assert_equal "9845894295", @new_user.mobile_number
    assert_not @new_user.invitation_token
    assert_equal @manager.company_id, @new_user.company_id
  end

  test "unsuccessful acceptance of an invite" do
    user_invite_op = User::Invite::Create.new(@manager,{invite: {company_id: @manager.company_id, email: 'user99@finlytest.io',
                                                                 role_mapping_attributes: [{user_role_id: 4}],
                                                                 team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}})
    assert_difference 'User.count', 1 do
      @new_user = user_invite_op.run
    end
    assert @new_user
    assert @new_user.employee?

    # trying invalid parameters to accept invite
    token = @new_user.raw_invitation_token
    name = 'test name'
    password = 'password'
    mobile_number = '9845894295'
    invite_accept_op = User::Invite::Accept.new(invitation_token: token, name: nil, mobile_number: mobile_number, password: password)
    @result = invite_accept_op.run
    assert_not @result
    assert @new_user.invitation_token

    invite_accept_op = User::Invite::Accept.new(invitation_token: "ksjgndsfgidsgsdfgdfsg", name: name, mobile_number: mobile_number, password: password)
    @result = invite_accept_op.run
    assert_not @result
    assert @new_user.invitation_token

    invite_accept_op = User::Invite::Accept.new(invitation_token: token, name: name, mobile_number: nil, password: password)
    @result = invite_accept_op.run
    assert_not @result
    assert @new_user.invitation_token

    invite_accept_op = User::Invite::Accept.new(invitation_token: token, name: name, mobile_number: mobile_number, password: nil)
    @result = invite_accept_op.run
    assert_not @result
    assert @new_user.invitation_token

  end
end