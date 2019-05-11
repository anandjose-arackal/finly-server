class Procure::QuotationsController < WebBase

  def index
    @result = Procurements::PurchaseOrders::Quotations::Index.(current_user, params)
    respond
  end

  def create
    @result = Procurements::PurchaseOrders::Quotations::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::PurchaseOrders::Quotations::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::PurchaseOrders::Quotations::Destroy.(current_user, params)
    respond
  end
end