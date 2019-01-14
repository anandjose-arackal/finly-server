class Kyc::CompaniesController < BaseControllers::WebBase


  before_action -> { finly_authorize! :web}

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

  # action that essentially lets the user retract their confirmation of documents and upload them again if required
  def retract
    @result = KycProcess::Company::Retract.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

end
