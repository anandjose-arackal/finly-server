class Api::Vp::V1::VendorsController < BaseControllers::ApiBase
  def index
    params[:route] = 'vendors.default'
    endpoint Resolver::Resolve
  end
end
