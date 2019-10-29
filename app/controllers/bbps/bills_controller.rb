class Bbps::BillsController < BaseControllers::WebBase
  def create
    result = UtilityBills::Bills::Ops::Create.(params)
    respond
  end
end