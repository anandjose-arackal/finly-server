class Macros::V1::InvoicesController < BaseControllers::MacrosBase

  def index
    params[:route] = 'invoices.default'
    endpoint Resolver::Resolve
  end

  def count
    params[:route] = 'invoices.default'
    endpoint Resolver::Resolve
  end

  def show
    endpoint Docs::P2P::Invoices::Ops::Show
  end

  def update
    endpoint Docs::P2P::Invoices::Ops::Update
  end

  def new_sync_attempt
    endpoint Macros::ErpSyncs::Create, args: [
        params: params.to_unsafe_h,
        current_user: current_user,
        record_class: Invoice
    ]
  end

end
