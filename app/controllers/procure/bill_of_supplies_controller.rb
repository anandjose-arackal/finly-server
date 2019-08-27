class Procure::BillOfSuppliesController < BaseControllers::WebBase

  def create
    @result = Procurements::BillOfSupplies::Create.(current_user, params)
    respond
  end

  def show
    @result = Procurements::BillOfSupplies::Show.(current_user, params)
    respond
  end

  def update
    @result = Procurements::BillOfSupplies::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::BillOfSupplies::Destroy.(current_user, params)
    respond
  end
end
