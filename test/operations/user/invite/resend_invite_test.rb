require 'test_helper'

class ResendInviteTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @employee = users(:employee)
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

  test "admin can resend an invite to a user whose invite has already been sent" do
    resend_invite_op = User::Invite::Resend.new(@admin, id: @new_user.id)
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size', 1 do
      @result = resend_invite_op.run
    end
    assert @result.success?
    assert @result.messages[:error].empty?
  end

  test "non admins cannot resend an invite for anyone" do
    # manager trying to resend an invitation
    resend_invite_op = User::Invite::Resend.new(@manager, id: @new_user.id)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      begin
        @result = resend_invite_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end

    # finance manager trying to resend an invitation
    resend_invite_op = User::Invite::Resend.new(@finance_manager, id: @new_user.id)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      begin
        @result = resend_invite_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
  end

  test "invite cannot be resent for a user who has already signed up" do
    # mocking the fact that the user has already signed up
    User.any_instance.stubs(:invitation_sent_at).returns(DateTime.now)
    User.any_instance.stubs(:invitation_accepted_at).returns(DateTime.now)

    resend_invite_op = User::Invite::Resend.new(@admin, id: @new_user.id)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      @result = resend_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Invite cannot be resent as user has already signed up with Finly", @result.messages[:error].first
  end

  test "invite cannot be resent for a user that does not exist in the database" do
    resend_invite_op = User::Invite::Resend.new(@admin, id: 200)
    assert_no_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
      @result = resend_invite_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Invite not found", @result.messages[:error].first
  end

end