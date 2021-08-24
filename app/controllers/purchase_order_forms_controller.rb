# Controller & Routes for the same to be migrated to InvoicesController after the following
#   -
class PurchaseOrderFormsController < BaseControllers::WebBase
  layout 'trailblazers'

  def show
    # binding.pry
    # endpoint Docs::I2P::Invoices::Ops::Show
    @result = Procurements::PurchaseOrders::Show.(current_user, params)
    respond
  end

  def update
    @result = Procurements::PurchaseOrders::Update.(current_user, params)
    respond
    # endpoint Docs::I2P::Invoices::Ops::Update
  end

  def save_and_submit

    @result = Procurements::PurchaseOrders::SaveSubmit.(current_user, params)
    if @result.success?
      respond
    else
      render file: 'procure/purchase_orders/save_submit'
    end

    # @op = Docs::I2P::Invoices::Ops::SaveAndSubmit.({params: params.to_unsafe_h, current_user: current_user})
    # respond_to do |format|
    #   format.json {}
    # end
  end
end