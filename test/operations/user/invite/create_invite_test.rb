# this test requires one user of each type and one non default policy

require 'test_helper'

class CreateInviteTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @employee = users(:employee)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)

    @policy = Policy.non_default.first
    @invite_params = {pending_invite: { company_id: 1,
                                        email: "test@test.com",
                                        note: "Test note.",
                                        team_mapping_attributes: {manager_id: @manager.id,
                                                                  finance_manager_id: @finance_manager.id},
                                        policy_id: @policy.id
                                      },
                      admin: "1",
                      manager: "0",
                      finance_manager: "0"
                     }
  end

  test "admins can invite new users into the system with a policy" do
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_difference 'User.count', 1 do
      assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size', 1 do
        @result = user_invite_op.run
      end
    end
    invited_user = @result.invite.first
    assert @result.success?
    assert_equal "test@test.com", invited_user.email
    assert invited_user.admin?
    assert invited_user.employee?
    # checking if the user has been added to the policy passed while creation
    assert @policy.users.include?(invited_user)
    # default policy + Test Policy for this user
    assert_equal 2, invited_user.policies.count
  end
  #
  # test "admins can invite new users to the system without a policy as well" do
  #
  #   # inviting the user without a policy setting ensures that he/she is only added to default
  #   @invite_params[:pending_invite][:policy_id] = ""
  #   user_invite_op = User::Invite::Create.new(@admin, @invite_params)
  #   assert_difference 'User.count', 1 do
  #     @result = user_invite_op.run
  #   end
  #   invited_user = @result.invite.first
  #   assert @result.success?
  #   assert_equal "test@test.com", invited_user.email
  #   assert invited_user.admin?
  #   assert invited_user.employee?
  #   # checking if the user has been added to the policy passed while creation
  #   assert_not @policy.users.include?(invited_user)
  #   # default policy + Test Policy for this user
  #   assert_equal 0, invited_user.policies.count
  # end
  #
  # test "managers and finance managers cannot invite other users" do
  #
  #   # trying to invite users as manager
  #   user_invite_op = User::Invite::Create.new(@manager, @invite_params)
  #   assert_no_difference 'User.count' do
  #     begin
  #       @result = user_invite_op.run
  #     rescue NotAuthorizedException
  #       @rescued = true
  #     end
  #   end
  #   assert @rescued
  #
  #   # trying to invite as finance manager
  #   user_invite_op = User::Invite::Create.new(@finance_manager, @invite_params)
  #   assert_no_difference 'User.count' do
  #     begin
  #       @result = user_invite_op.run
  #     rescue NotAuthorizedException
  #       @rescued = true
  #     end
  #   end
  #   assert @rescued
  #
  # end
  #
  # test "cannot invite user whose email id already exists in the system" do
  #   @invite_params[:pending_invite][:email] = "manager0@finlytest.io"
  #   user_invite_op = User::Invite::Create.new(@admin, @invite_params)
  #   assert_no_difference 'User.count' do
  #     @result = user_invite_op.run
  #   end
  #   assert_not @result.success?
  #   assert_not @result.messages[:error].empty?
  #
  # end
  #
  # test "cannot invite a user without a valid company ID" do
  #   # leaving the company id blank
  #   @invite_params[:pending_invite][:company_id] = ""
  #   user_invite_op = User::Invite::Create.new(@admin, @invite_params)
  #   assert_no_difference 'User.count' do
  #     @result = user_invite_op.run
  #   end
  #   assert_not @result.success?
  #   assert_not @result.messages[:error].empty?
  #
  #   # entering an invalid company_id or a different company_id
  #   @invite_params[:pending_invite][:company_id] = 2
  #   user_invite_op = User::Invite::Create.new(@admin, @invite_params)
  #   assert_no_difference 'User.count' do
  #     @result = user_invite_op.run
  #   end
  #   assert_not @result.success?
  #   assert_not @result.messages[:error].empty?
  # end

end