class AgreementController < ApplicationController
  allow_oauth!
  before_action :authenticate_user!, only: [:validate, :agree]
  def index
    @result = Agreements::Index.(nil, params)
    respond
  end

  def validate
    @result = Agreements::Validate.(current_user, params)
    # if @result.success?
    #   respnod response: :validate
    #   return
    # end
    # # respond response: :validate
  end

  def agree
    params[:ip_address] = request.remote_ip
    @result = Agreements::Agree.(current_user, params)
    respond
  end

end