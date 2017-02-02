class SessionsController < Devise::SessionsController

  respond_to :json

  def new
    super()
  end

  def create
    super()
  end

  def destroy
    super()
  end
  
end