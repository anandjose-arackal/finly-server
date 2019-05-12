class Procure::EWayBillsController < BaseControllers::WebBase

  def create
    @result = Procurements::EWayBills::Create.(current_user, params)
    respond
  end

  def show
    @result = Procurements::EWayBills::Show.(current_user, params)
    respond
  end

  def update
    @result = Procurements::EWayBills::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::EWayBills::Destroy.(current_user, params)
    respond
  end
end
