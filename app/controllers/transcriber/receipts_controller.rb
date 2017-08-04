class Transcriber::ReceiptsController < ApplicationController

  before_action -> { finly_authorize! :admin }

  def show

  end

  def index
    @result = Transcriber::Receipts::Index.(current_user, params)
    respond
  end

end
