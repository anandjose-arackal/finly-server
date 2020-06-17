class HoverCardController < BaseControllers::WebBase

  def route
    result = HoverCard::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
    if result.success?
      render json: {success: true, data: result["data"]}
    else
      # todo update format
      respond response: :failure, message: "Invalid Request"
    end
  end
  
end
