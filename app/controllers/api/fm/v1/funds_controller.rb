class Api::Fm::V1::FundsController < ApiApplicationController

  def credit
    formatted_param = RequestFormatter::Api::Fm::V1::Funds::CreditDebit.(current_user, params)&.formatted_request
    formatted_param[:validate_password]  = false
    @result = User::Wallet::Credit.(current_user, formatted_param)
    respond response: (@result&.success? ? :success : :failure)
  end

  def debit
    formatted_param = RequestFormatter::Api::Fm::V1::Funds::CreditDebit.(current_user, params)&.formatted_request
    formatted_param[:validate_password]  = false
    @result = User::Wallet::Debit.(current_user, formatted_param)
    respond response: (@result&.success? ? :success : :failure)
  end

end
