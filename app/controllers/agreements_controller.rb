class AgreementsController < ApplicationController

  before_action -> { doorkeeper_authorize! :web} , only: [:validate, :agree, :company_data]

  def company_data
    @result = Agreements::Company::Show.(current_user, params)
    respond
  end

  def index
    @result = Agreements::Index.(nil, params)
    respond
  end

  def validate
    @result = Agreements::Validate.(current_user, params)
    respond
  end

  def agree
    params[:ip_address] = request.remote_ip
    @result = Agreements::Agree.(current_user, params)
    respond
  end

  def update
    @result = Agreements::Kyc::Update.(current_user, params)
    respond
  end

end