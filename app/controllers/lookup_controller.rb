class LookupController < BaseControllers::WebBase
  def route
    result = Lookup::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
    if result.success?
      render json: {success: true, headers: result['headers'], data: result["model.records.json"]}
    else
      # todo update format
      respond response: :failure, message: "Invalid Request"
    end
  end
end
