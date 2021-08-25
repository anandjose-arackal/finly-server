# Controller & Routes for the same to be migrated to InvoicesController after the following
class PurchaseOrderFormsController < BaseControllers::WebBase
  layout 'trailblazers'

  def show
    endpoint Docs::I2P::PurchaseOrders::Ops::Show
  end

  def update
    endpoint Docs::I2P::PurchaseOrders::Ops::Update
  end

  def save_and_submit
    @op = Docs::I2P::Invoices::Ops::PurchaseOrders.({params: params.to_unsafe_h, current_user: current_user})
    respond_to do |format|
      format.json {}
    end
  end
end