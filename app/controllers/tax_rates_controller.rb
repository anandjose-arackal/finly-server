class TaxRatesController < BaseControllers::WebBase

  def create
    @result = TaxRates::Create.(current_user, params)
    respond_success_failure
  end

  def destroy
    @result = TaxRates::Destroy.(current_user, params)
    respond_success_failure
  end

  def index
    @result = TaxRates::Index.(current_user, params)
    respond
  end
end
