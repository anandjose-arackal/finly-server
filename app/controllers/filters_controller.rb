class FiltersController < BaseControllers::WebBase

  def index
    @op = ::Filters::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
  end

end
