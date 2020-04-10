class FiltersController < BaseControllers::WebBase
  layout 'trailblazers'

  def index
    @op = ::Filters::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
  end

  def choices
    endpoint ::Filters::Choices
  end

end
