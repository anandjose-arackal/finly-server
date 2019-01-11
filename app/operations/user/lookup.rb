# operation that return if the user is:
# a) registered - i.e. the user's credentials are located in our database
# b) verified - The User's KYC details have been logged in the system and (if the user was invited through mobile number) is yet to set a password

class User::Lookup < User::Base

  attr_accessor :selected_user, :registered, :verified, :otp_verified, :default_password

  def self.call(params)
    self.new(nil, params).run
  end

  def pre_validate

  end

  def init
    self.selected_user = User.find_for_database_authentication(username: params[:email_mobile])
  end

  def process
    if selected_user.nil?
      add_message :error, 'User not found'
      self.registered = false
      return
    elsif selected_user.first_name.blank?
      if selected_user.default_password
        self.default_password = true
      end
      self.registered = false
      add_message :error, 'You have not signed up with Finly yet! Please contact your manager for further details'
      return
    else
      if selected_user.default_password
        self.default_password = true
      end
      if selected_user.active?
        self.registered = true
      else
        add_message :error, 'Your account has been deactivated'
        self.registered = false
        return
      end
    end
    self.verified = selected_user.verified
    self.otp_verified = selected_user.otp_verified
  end

  def success
    params[:registered] = self.registered
    if selected_user.present?
      number = selected_user.mobile_number
      params[:id] = selected_user.id
      params[:mobile_number] = "XXXXXXX#{number[(number.length-3)..number.length]}"
    end
    params[:verified] = self.verified
    params[:otp_verified] = self.otp_verified
    params[:set_password] = self.default_password
    User::Lookup::LookupPresenter.new(user, params, messages)
  end

  class User::Lookup::LookupPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :verified, :registered, :otp_verified, :set_password, :mobile_number

    def init
      self.verified = params[:verified]
      self.registered = params[:registered]
      self.otp_verified = params[:otp_verified]
      self.set_password = params[:set_password]
      if params[:set_password]
        self.mobile_number = params[:mobile_number]
      end
    end

  end

end
