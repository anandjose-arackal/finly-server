class Kyc::CompaniesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def show
    @result = KycProcess::Company::Show.(current_user, params)
    respond
  end

  def update
    @result = KycProcess::Company::Update.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def confirm
    # this action updates the status of the KYC from submitted to processing
    @result = KycProcess::Company::Confirm.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

end
