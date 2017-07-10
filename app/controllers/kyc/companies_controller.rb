class Kyc::CompaniesController < ApplicationController


  before_action -> { doorkeeper_authorize! :web}

  def show
    @result = KycProcess::Company::Show.(current_user, params)
    respond
  end

  def update
    @result = KycProcess::Company::Update.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

end
