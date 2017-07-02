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

end
