class OtpController < ApplicationController
  before_action :authenticate_user!

  # params = {user: {mobile_number}}
  def update
    @result = User::Configuration::UpdateMobileNumber.(current_user, params)
    respond_to do |format|
      format.json {render {}}
    end

  end

  def resend
    @result = User::Verification::Otp::Create.(current_user, params)
    respond response: :success
  end

  # params = {verification_code: '123456'}
  def verify
    @result = User::Verification::Otp::Verify.(current_user, params)
    respond response: :success
  end

end
