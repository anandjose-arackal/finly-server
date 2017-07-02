class Transcriber::ReceiptsController < ApplicationController


  before_action :authenticate_user!
  allow_oauth!

  def show

  end

  def index
    @result = Transcriber::Receipts::Index.(current_user, params)
    respond
  end

end
