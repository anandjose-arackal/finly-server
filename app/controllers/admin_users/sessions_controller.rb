class AdminUsers::SessionsController < Devise::SessionsController

  prepend_before_action :verify_signed_out_user, except: [:new, :create, :destroy]
  respond_to :json

  before_action -> { doorkeeper_authorize! :admin}

  def new
    super()
  end

  def create
    # super()
    self.resource = warden.authenticate!(auth_options)
    # set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    # adding the user as a resource
    @user = resource
    respond_to do |format|
      format.json { render json: {success: true, otp_verified: @user.otp_verified}}
    end
  end

  def destroy
    # SIGN OUT FOR TOKEN AUTHENTICATION
    # Deleting the cookies set while authenticating tokens in TokensController#create
    cookies.delete "access_token"
    cookies.delete "refresh_token"

    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out

    respond_to do |format|
      format.html { redirect_to redirect_path }
      format.json { render :json => {:success => true} }
    end

    # SHALL NOT WORK WITH REGULAR SIGN OUT METHOD! :(
    # super()
  end

end
