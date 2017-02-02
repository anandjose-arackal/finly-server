# operation that return if the user is:
# a) registered - i.e. the user's credentials are located in our database
# b) verified - The User's KYC details have been logged in the system and (if the user was invited through mobile number) is yet to set a password

class User::Lookup < User::Base

  attr_accessor :selected_user, :registered, :verified

  def pre_validate

  end

  def init
    self.selected_user = User.find_by_email_or_mobile_number(login_params[:email])
  end

  def process
    if selected_user.nil?
      self.registered = false
      self.verified = false
      return
    else
      self.registered = true
    end
    if selected_user.first_name and selected_user.password
      self.verified = true
    else
      self.verified = false
    end
  end

  def success
    params[:registered] = registered
    params[:verified] = verified
  end

  class User::Lookup::LookupPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :verified, :registered

    def init
      self.verified = params[:verified]
      self.registered = params[:registered]
    end
  end

  private

  def login_params
    params.require(:user).permit(:email)
  end
end