class RateContractsController < ApplicationController

  def index
    @result = RateContracts::Index.(current_user, params)
    respond
  end

  def show
    @result = RateContracts::Show.(current_user, params)
    respond
  end

  def create
    @result = RateContracts::Create.(current_user, params)
    respond
  end

  def update
    @result = RateContracts::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = RateContracts::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def configuration
    @result = RateContracts::Configuration::Show.(current_user, params)
    respond
  end
end
