class Api::Vp::V1::PurchaseOrdersController < BaseControllers::ApiBase
  def index
    params[:route] = 'purchase_orders.default'
    endpoint Resolver::Resolve
  end
end
