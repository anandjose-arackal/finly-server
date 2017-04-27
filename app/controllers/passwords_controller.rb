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
    set_params

    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    respond_to do |format|
      format.json {
        if resource.errors.empty?
          # set the default password flag to be false
          resource.update(default_password: false)
          respond response: :success, message: "Password reset successfully"
        else
          respond response: :failure, message: resource.errors.full_messages.to_sentence
        end
      }
    end
  end

  private

  def set_params
    params[:user] = {
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        reset_password_token: params[:reset_password_token]
    }
  end
end
