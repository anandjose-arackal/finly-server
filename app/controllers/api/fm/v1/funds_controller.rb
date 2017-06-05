class Api::Fm::V1::FundsController < ApplicationController

  allow_oauth!
  before_action :authenticate_user!

  def credit
    params[:validate_password] = false
    @result = User::Wallet::Credit.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def debit
    params[:validate_password] = false
    @result = User::Wallet::Debit.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
