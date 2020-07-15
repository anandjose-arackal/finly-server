class Macros::V1::InvoicesController < BaseControllers::MacrosBase
  layout 'trailblazers'

  def index
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
        policy: [Docs::P2P::Invoices::Policy, :erp_sync?],
        record_class: Invoice,
        record_key: :invoice_id
    ]
  end

end
