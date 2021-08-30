class Api::Vp::V1::PurchaseOrderController < BaseControllers::ApiBase
  def index
    params[:route] = 'purchase_orders.default'
    endpoint Resolver::Resolve
  end
end
