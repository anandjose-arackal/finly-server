require 'test_helper'

class DestroyInviteTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by email: 'manager0@finlytest.io'
    @finance_manager = User.find_by email: 'finance0@finlytest.io'
    @employee = User.find_by email: 'user0@finlytest.io'
    @invite_params = {pending_invite: { company_id: 1,
                                        email: "test@test.com",
                                        note: "Test note.",
                                        team_mapping_attributes: {},
                                        policy_id: ""
                                      },
                      admin: "1",
                      manager: "0",
                      finance_manager: "0"
                    }
    @new_user = User::Invite::Create.(@admin, @invite_params).invite.first
  end

  test "successfully destroying an invite by a company admin" do
    # admin destroying an invite
    destroy_op = User::Invite::Destroy.new(@admin, id: @new_user.id)
    assert_difference 'User.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not User.exists?(@new_user.id)
  end

  test "non company admins cannot destroy an invites" do
    # employee trying to destroy an invite
    destroy_op = User::Invite::Destroy.new(@employee, id: @new_user.id)
    assert_no_difference 'User.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert User.exists?(@new_user.id)

    # finance manager trying to destroy an invite
    destroy_op = User::Invite::Destroy.new(@finance_manager, id: @new_user.id)
    assert_no_difference 'User.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert User.exists?(@new_user.id)

    # manager trying to destroy an invite
    destroy_op = User::Invite::Destroy.new(@manager, id: @new_user.id)
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

  test "cannot destroy a user that has accepted his/her invite" do
    destroy_op = User::Invite::Destroy.new(@admin, id: @employee.id)
    assert_no_difference 'User.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert User.exists?(@employee.id)
  end

end