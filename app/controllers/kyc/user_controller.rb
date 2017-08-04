class Kyc::UserController < ApplicationController


  before_action -> { finly_authorize! :web}

  def show
    @result = KycProcess::User::Show.(current_user, params)
    respond
  end

  def update
    @result = KycProcess::User::Update.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

end
