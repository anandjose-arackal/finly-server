require 'test_helper'

class AcceptInviteTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @employee = users(:employee)
    @invite_params = {pending_invite: { company_id: 1,
                                                         email: "test@test.com",
                                                         note: "Test note.",
                                                         team_mapping_attributes: {manager_id: @manager.id,
                                                                                   finance_manager_id: @finance_manager.id}
                                      },
                                       admin: "1",
                                       manager: "0",
                                       finance_manager: "0"
                      }
    @invited_user = User::Invite::Create.(@admin, @invite_params).invite.first
    invitation_token = @invited_user.raw_invitation_token
    @valid_accept_params = {user: { invitation_token: invitation_token, # will be added after getting a valid invite token
                                    password: "password007",
                                    password_confirmation: "password007",
                                    mobile_number: "8105739684",
                                    first_name: "Hello",
                                    last_name: "World",
                                    profile_attributes: { date_of_birth: "2006-01-01",
                                                          gender: "m",
                                                          address_1: "Malleshwaram",
                                                          address_2: "Bangalore",
                                                          city: "Bangalore",
                                                          state_id: "S18",
                                                          pin_code: "560003"
                                                        }
                                  }
                           }

  end

  test "successful acceptance of an invite" do

    # mocking the post_process method so that the OTP API isn't called unnecessarily
    User::Invite::Accept.any_instance.stubs(:post_process).returns(true)

    # accepting an invite by a user
    invite_accept_op = User::Invite::Accept.new(nil, @valid_accept_params)

    @result = invite_accept_op.run
    assert @result.success?
    @new_user = @result.accepted_user
    assert @new_user
    assert_equal "test@test.com", @new_user.email
    assert_equal "Hello World", @new_user.name
    assert_equal "8105739684", @new_user.mobile_number
    assert_not @new_user.invitation_token
    assert_equal @admin.company_id, @new_user.company_id
    assert @new_user.invite_accepted?
  end

  test "unsuccessful acceptance of an invite due to invalid parameters" do
    # invalid mobile number
    @valid_accept_params[:user][:mobile_number] = "1234567892"
    accept_op = User::Invite::Accept.new(nil, @valid_accept_params)
    @result = accept_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Please enter a valid mobile number", @result.messages[:error].first

    # invalid password
    @valid_accept_params[:user][:mobile_number] = "8105739684"
    @valid_accept_params[:user][:password] = "1234567892"
    accept_op = User::Invite::Accept.new(nil, @valid_accept_params)
    @result = accept_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Confirmation password does not match the given password", @result.messages[:error].first

    # invalid pin code
    @valid_accept_params[:user][:password] = "password007"
    @valid_accept_params[:user][:profile_attributes][:pin_code] = "12345621321"
    accept_op = User::Invite::Accept.new(nil, @valid_accept_params)
    @result = accept_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Invalid Pincode entered", @result.messages[:error].first
  end

  test "" do

  end

end