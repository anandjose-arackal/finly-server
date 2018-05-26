class Procure::PurchaseOrdersController < ApplicationController
  before_action -> { finly_authorize! :web }

  def show

  end

  def create
    @result = Procurements::PurchaseOrders::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::PurchaseOrders::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::PurchaseOrders::Destroy.(current_user, params)
    respond
  end

  def send_mail
    @result = Procurements::PurchaseOrders::SendMail.(current_user, params)
    respond
  end
end