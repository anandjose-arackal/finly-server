class Macros::V1::InvoicesController < BaseControllers::MacrosBase
  layout 'trailblazers'

  def index
    params[:route] = 'invoices.default'
    endpoint Resolver::Resolve
  end

  def show
    endpoint Docs::P2P::Invoices::Show
  end

end
