class FiltersController < BaseControllers::WebBase

  def index
    op = ::Filters::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
    if op.success?
      render json: {success: true, data: op[:filters]}
    else
      # todo update format
      respond response: :failure, message: "Invalid Request"
    end
  end

end
