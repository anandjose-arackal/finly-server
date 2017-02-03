class PasswordsController < Devise::PasswordsController

  def new
    super()
  end

  def create
    if params[:user][:email] =~ Constants::VALID_EMAIL_FORMAT
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      else
        flash[:error] = resource.errors.full_messages.to_sentence
        respond_with(resource)
      end
    else
      @result = User::Password::SendResetPasswordOtp.(params)
      if @result.success?
        flash[:notice] = @result.messages[:success].to_sentence
        redirect_to verify_reset_password_otp_path
      else
        flash[:error] = @result.messages[:error].to_sentence
        redirect_to request.referrer
      end
    end
  end

  def edit
    super()
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:error, flash_message)
        sign_in(resource_name, resource)
      else
        set_flash_message!(:error, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      flash[:error] = resource.errors.full_messages.to_sentence
      respond_with resource
    end
  end

  # action that lets mobile only users set their password for the first time
  # also the action that mobile users use to set their password if they've forgotten it
  def set_new
    @result = User::Login::SetPassword.(nil, params)
    if @result.success?
      # log in and redirect to root URL
      sign_in @result.user, :bypass => true
      redirect_to root_url
    else
      # show error message
      flash[:error] = @result.messages[:error]
      redirect_to request.referrer
    end
  end


end
