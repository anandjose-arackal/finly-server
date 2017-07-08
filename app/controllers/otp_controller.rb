class OtpController < ApplicationController


  before_action :doorkeeper_authorize!

  def edit
  end

  # params = {user: {mobile_number: '1293491827'}}
  def update
    @result = User::Configuration::UpdateMobileNumber.(current_user, params)
    if @result.success?
      flash[:success] = @result.messages[:success].first rescue nil
    else
      flash[:failure] = @result.messages[:error].first rescue nil
    end
    respond
  end

  def resend
    params[:type] = OtpRequestType.id_for(:user_verification)
    @result = User::Verification::Otp::Create.(current_user, params)
    if @result.success?
      flash[:success] = @result.messages[:success].first rescue nil
      respond response: :success
    else
      flash[:failure] = @result.messages[:error].first rescue nil
      respond response: :failure
    end
  end

  # params = {verification_code: '123456'}
  def verify
    @result = User::Verification::Otp::Verify.(current_user, params)
    if @result.success?
      flash[:success] = @result.messages[:success].first rescue nil
      respond response: :success
    else
      flash[:failure] = @result.messages[:error].first rescue nil
      respond response: :failure
    end
  end


end
