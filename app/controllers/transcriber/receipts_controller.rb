class Transcriber::ReceiptsController < BaseControllers::AdminBase


  def show

  end

  def index
    @result = Transcriber::Receipts::Index.(current_user, params)
    respond
  end

  def count
    @result = Transcriber::Receipts::Count.(current_user, params)
    render json: @result.count.as_json
  end

end
