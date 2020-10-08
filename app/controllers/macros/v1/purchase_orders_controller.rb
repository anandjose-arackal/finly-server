class Macros::V1::PurchaseOrdersController < BaseControllers::MacrosBase

  def index
    params[:route] = 'purchase_orders.default'
    endpoint Resolver::Resolve
  end

  def count
    params[:route] = 'purchase_orders.default'
    endpoint Resolver::Resolve
  end

  def show
  end

  def update
  end

  def new_sync_attempt
    endpoint Macros::ErpSyncs::Create, args: [
        params: params.to_unsafe_h,
        current_user: current_user,
        record_class: Invoice
    ]
  end

end