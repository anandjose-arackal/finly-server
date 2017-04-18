class PasswordsController < Devise::PasswordsController

  respond_to :json

  def new
    super()
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      @result = {
          success: true,
          messages: {
              success: ["Password reset intructions sent. Check you mail!"]
          }
      }
      render json: @result.as_json
    else
      flash[:error] = resource.errors.full_messages.to_sentence
      respond_with(resource)
    end
  end

  def edit
    super()
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    respond_to do |format|
      format.json {
        if resource.errors.empty?
          respond response: :success, message: "Password reset successfully"
        else
          respond response: :failure, message: resource.errors.full_messages.to_sentence
        end
      }
    end

    # if resource.errors.empty?
    #   resource.unlock_access! if unlockable?(resource)
    #   if Devise.sign_in_after_reset_password
    #     flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
    #     set_flash_message!(:error, flash_message)
    #     sign_in(resource_name, resource)
    #   else
    #     set_flash_message!(:error, :updated_not_active)
    #   end
    #   respond_with resource, location: after_resetting_password_path_for(resource)
    # else
    #   set_minimum_password_length
    #   flash[:error] = resource.errors.full_messages.to_sentence
    #   respond_with resource
    # end
  end
end
