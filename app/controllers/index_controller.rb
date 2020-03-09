class IndexController < BaseControllers::WebBase
  layout 'trailblazers'

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
    debugger
    if @op.success?
      render json: {success: true, data: @op['model.index']}
    else
      respond response: :failure, message: "Invalid Request"
    end
  end

  def status_counts
    endpoint IndexBuilder::StatusCount
    if @op.success?
      render json: {success: true, data: @op['counter']}
    else
      respond response: :failure, message: "Invalid Request"
    end
  end

  def record_counts
    endpoint IndexBuilder::RecordCount
    if @op.success?
      render json: {success: true, data: @op['counter']}
    else
      respond response: :failure, message: "Invalid Request"
    end
  end

end
