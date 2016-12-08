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
                      finance_manager: "0",
                      type: 'email'
                     }

    @mobile_invite_params = {pending_invite: { company_id: 1,
                                               mobile_number: "8105739684, 8052525252",
                                               note: "Test note.",
                                               team_mapping_attributes: {manager_id: @manager.id,
                                                                         finance_manager_id: @finance_manager.id},
                                               policy_id: @policy.id
                                              },
                             admin: "1",
                             manager: "0",
                             finance_manager: "0",
                             type: 'mobile'
                            }
  end

  # test "testing mocha expects" do
  #   u = User.find(2)
  #   User.expects(:find).with(2).returns(@admin)
  #   assert_not_equal u.id, @admin.id
  #   assert_equal @admin.id, User.find(2).id
  # end

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
    assert_equal 1, invited_user.policies.count
  end

  test "admins can invite new users to the system without a policy as well" do

    # inviting the user without a policy setting ensures that he/she is only added to default
    @invite_params[:pending_invite][:policy_id] = ""
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
    assert_not @policy.users.include?(invited_user)
    # ensure the user is not explicitly a part of a policy
    assert_equal 0, invited_user.policies.count
  end

  test "managers and finance managers cannot invite other users" do
    # trying to invite users as manager
    user_invite_op = User::Invite::Create.new(@manager, @invite_params)
    assert_no_difference 'User.count' do
      begin
        @result = user_invite_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued

    # trying to invite as finance manager
    user_invite_op = User::Invite::Create.new(@finance_manager, @invite_params)
    assert_no_difference 'User.count' do
      begin
        @result = user_invite_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end

  test "cannot invite user whose email id already exists in the system" do
    @invite_params[:pending_invite][:email] = "manager0@finlytest.io"
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_no_difference 'User.count' do
      @result = user_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Following emails are already invited: manager@finlytest.io", @result.messages[:error].first
  end

  test "cannot invite a user without a valid company ID" do
    # leaving the company id blank
    @invite_params[:pending_invite][:company_id] = ""
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_no_difference 'User.count' do
      @result = user_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?

    # entering an invalid company_id or a different company_id
    @invite_params[:pending_invite][:company_id] = 2
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_no_difference 'User.count' do
      @result = user_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
  end

  test "adding comma separated emails adds all the users with valid email addresses" do
    @invite_params[:pending_invite][:email] = "test@test.com, abc@test.com, hello@world.com"
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_difference 'User.count', 3 do
      assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size', 3 do
        @result = user_invite_op.run
      end
    end
    assert @result.success?
    invited_users = @result.invite
    assert_equal 3, invited_users.count
    assert_equal "test@test.com", invited_users.first.email
    assert_equal "abc@test.com", invited_users.second.email
    assert_equal "hello@world.com", invited_users.third.email

    invited_users.each do |user|
      assert user.admin?
      assert user.employee?
      # checking if the user has been added to the policy passed while creation
      assert @policy.users.include?(user)
      # default policy + Test Policy for this user
      assert_equal 1, user.policies.count
    end
  end

  test "cannot invite a user without a valid email" do
    # invalid email format
    @invite_params[:pending_invite][:email] = "say whaaaa"
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_no_difference 'User.count' do
      @result = user_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?

    # blank email id
    @invite_params[:pending_invite][:email] = ""
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_no_difference 'User.count' do
      @result = user_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?

    # another invalid format, because hey this is fun
    @invite_params[:pending_invite][:email] = "asdf@asdf"
    user_invite_op = User::Invite::Create.new(@admin, @invite_params)
    assert_no_difference 'User.count' do
      @result = user_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
  end

  test "if users are being invited via mobile number, email doesn't have to be present" do

  end

  test "admin can invite a user with just a mobile number into the system" do

  end

end