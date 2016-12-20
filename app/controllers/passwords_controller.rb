class PasswordsController < Devise::PasswordsController

  def new
    super()
  end

  def create
    if params[:user][:email] =~ Constants::VALID_EMAIL_FORMAT
      super()
    else
      @result = User::TemporaryPassword.(params)
      if @result.success?
        flash[:notice] = @result.messages[:success].to_sentence
        redirect_to new_user_session_path
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
    super()
  end


end
