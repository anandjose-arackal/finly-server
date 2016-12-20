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
        respond reponse: :success
      else
        respond reponse: :failure
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
