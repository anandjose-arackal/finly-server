class Procure::DeliveryChallansController < BaseControllers::WebBase

  def create
    @result = Procurements::DeliveryChallans::Create.(current_user, params)
    respond
  end

  def show
    @result = Procurements::DeliveryChallans::Show.(current_user, params)
    respond
  end

  def update
    @result = Procurements::DeliveryChallans::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::DeliveryChallans::Destroy.(current_user, params)
    respond
  end
end
