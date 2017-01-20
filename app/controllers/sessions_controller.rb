class SessionsController < Devise::SessionsController

  def new
    super()
  end

  def create
    # if the type is password, use the standard method of login
    if params[:type] == 'password'
      super()
    # if type is otp, use operation
    elsif params[:type] == 'otp'
      @result = User::OtpLogin.(params)
      if @result.success?
        # sign in the user and redirect
      else
        # throw error message
      end
    end
  end

  # action that sends an otp to the number that is passed
  def send_otp

  end


  def destroy
    super()
  end
  
end