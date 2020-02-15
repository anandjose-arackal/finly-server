class IndexController < BaseController::WebBase

  def config
    endpoint IndexBuilder::Show
    if @op.success?
      render json: {success: true, data: @op['model.index']}
    else
      respond response: :failure, message: "Invalid Request"
    end
  end

  def show

  end

end
