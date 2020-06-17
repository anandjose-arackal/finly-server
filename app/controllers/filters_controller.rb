class FiltersController < BaseControllers::WebBase
  layout 'trailblazers'

  def index
    endpoint ::Filters::Config
  end

  def show
    @op = ::Filters::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
  end

  def choices
    endpoint ::Filters::Choices
  end

end
