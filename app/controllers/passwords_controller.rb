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
  end
end
