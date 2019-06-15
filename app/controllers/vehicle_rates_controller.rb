class VehicleRatesController < BaseControllers::WebBase

  def create
    @result = Policy::VehicleRates::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  def destroy
    @result = Policy::VehicleRates::Destroy.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

end
