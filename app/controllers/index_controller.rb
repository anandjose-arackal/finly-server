class IndexController < BaseControllers::WebBase

  def fetch_config
    endpoint IndexBuilder::Config
    if @op.success?
      render json: {success: true, data: @op[:config]}
    else
      respond response: :failure, message: "Invalid Request"
    end
  end

  def show
    endpoint IndexBuilder::Show
    if @op.success?
      render json: {success: true, data: @op['model.index']}
    else
      respond response: :failure, message: "Invalid Request"
    end
  end

end
