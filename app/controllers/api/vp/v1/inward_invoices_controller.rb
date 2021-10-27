class Api::Vp::V1::InwardInvoicesController < BaseControllers::ApiBase
  def index
    params[:route] = 'invoices.default'
    endpoint Resolver::Resolve
  end
end
