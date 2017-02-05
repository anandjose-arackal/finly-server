class SessionsController < Devise::SessionsController

  respond_to :json

  def new
    super()
  end

  def create
    # super()
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    # adding the user as a resource
    @user = resource
    respond_to do |format|
      format.json { render json: {success: true, otp_verified: @user.otp_verified}}
    end
  end

  def destroy
    super()
  end
  
end