# operation that return if the user is:
# a) registered - i.e. the user's credentials are located in our database
# b) verified - The User's KYC details have been logged in the system and (if the user was invited through mobile number) is yet to set a password

class User::Lookup < User::Base

  attr_accessor :selected_user, :registered, :verified, :otp_verified

  def self.call(params)
    self.new(nil, params).run
  end

  def pre_validate

  end

  def init
    self.selected_user = User.find_by_email(params[:email_mobile]) || User.find_by(mobile_number: params[:email_mobile])
  end

  def process
    if selected_user.nil?
      add_message :error, "User not found"
      self.registered = false
      self.verified = false
      return
    else
      if selected_user.active?
        self.registered = true
      else
        add_message :error, "Your account has been deactivated"
        self.registered = false
        self.verified = false
        return
      end
    end

    self.verified = selected_user.verified
    self.otp_verified = selected_user.otp_verified
  end

  def success
    params[:registered] = registered
    params[:verified] = verified
    User::Lookup::LookupPresenter.new(user, params, messages)
  end

  class User::Lookup::LookupPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :verified, :registered

    def init
      self.verified = params[:verified]
      self.registered = params[:registered]
    end
  end

  private

end