class Mobile::V1::Kyc::UserController < BaseControllers::MobileBase


  def show
    @result = KycProcess::User::Show.(current_user, params)
    respond
  end

  def update
    formatted_request = RequestFormatter::KycParser::Parse.(current_user, params).formatted_request
    @result = KycProcess::User::Update.(current_user, formatted_request)
    respond response: @result&.success? ? :success : :failure
  end

  def update_and_submit
    formatted_request = RequestFormatter::KycParser::Parse.(current_user, params).formatted_request
    @result = KycProcess::User::Update.(current_user, formatted_request)
    unless @result&.success?
      respond response: :failure
      return
    end
    @result = KycProcess::User::Submit.(current_user, formatted_request)
    respond response: @result&.success? ? :success : :failure
  end

  def submit
    @result = KycProcess::User::Submit.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def retract
    @result = KycProcess::User::Retract.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

end
