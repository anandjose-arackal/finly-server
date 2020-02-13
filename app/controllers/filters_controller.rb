class FiltersController < BaseControllers::WebBase

  def index
    result = ::Filters::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
    if result.success?
      render json: {success: true, data: result[:filters]}
    else
      # todo update format
      respond response: :failure, message: "Invalid Request"
    end
  end

end
