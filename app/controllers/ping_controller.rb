class PingController < ApplicationController

  def ping
    render json: {success: true}
  end

end
