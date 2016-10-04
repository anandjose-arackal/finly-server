class OtpController < ApplicationController
  before_action :authenticate_user!

  def edit
  end

  # params = {user: {mobile_number: '1293491827'}}
  def update
    @result = User::Configuration::UpdateMobileNumber.(current_user, params)
    respond
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
