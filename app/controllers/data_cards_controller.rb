class DataCardsController < BaseControllers::WebBase

  def show
    @op = DataCards::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
    if @op.success?
      render json: {success: true, data: @op[:result]}
    else
      # todo update format
      respond response: :failure, message: "Invalid Request"
    end
  end

end
