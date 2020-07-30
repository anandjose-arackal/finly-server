class Macros::V1::VendorsController < BaseControllers::MacrosBase

  def index
    params[:route] = 'vendors.default'
    endpoint Resolver::Resolve
  end

  def count
    params[:route] = 'vendors.default'
    endpoint Resolver::Resolve
  end

  def show
    endpoint Masters::Vendors::Ops::Show
  end

  def update
    # Todo
    # endpoint Masters::Vendors::Ops::Update
  end

  def new_sync_attempt
    endpoint Macros::ErpSyncs::Create, args: [
        params: params.to_unsafe_h,
        current_user: current_user,
        record_class: Invoice
    ]
  end

end
