require 'test_helper'

class DestroyInviteTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by email: 'manager0@finlytest.io'
    @finance_manager = User.find_by email: 'finance0@finlytest.io'
    @employee = User.find_by email: 'user0@finlytest.io'
    @new_user = User::Invite::Create.new(@manager,{invite: {company_id: @manager.company_id, email: 'user99@finlytest.io',
                                                            role_mapping_attributes: [{user_role_id: 4}],
                                                            team_mapping_attributes: [{default: true, manager_id: @manager.id, finance_manager_id: @finance_manager.id}]}}).run
  end

  test "successfully destroying an invite by an admin" do
    # admin destroying an invite
    destroy_op = User::Invite::Destroy.new(@admin, invited_user_id: @new_user.id)
    assert_difference 'User.count', -1 do
      @result = destroy_op.run
    end
    assert_not User.exists?(@new_user.id)

  end

  test "successfully destroying an invite by inviter" do
    # inviting manager destroying an invite
    destroy_op = User::Invite::Destroy.new(@manager, invited_user_id: @new_user.id)
    assert_difference 'User.count', -1 do
      @result = destroy_op.run
    end
    assert_not User.exists?(@new_user.id)
  end

  test "non admins or non inviting users cannot destroy invites" do
    # employee trying to destroy an invite
    destroy_op = User::Invite::Destroy.new(@employee, invited_user_id: @new_user.id)
    assert_no_difference 'User.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert User.exists?(@new_user.id)

    # non-inviting manager trying to destroy an invite
    destroy_op = User::Invite::Destroy.new(@finance_manager, invited_user_id: @new_user.id)
    assert_no_difference 'User.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert User.exists?(@new_user.id)
  end
end