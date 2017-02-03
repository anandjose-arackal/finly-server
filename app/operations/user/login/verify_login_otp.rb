# action that verifies the login otp of the user

class User::Login::VerifyLoginOtp < BaseOperation

  def self.call(user, params)
    self.new(nil, params).run
  end

  def pre_validate
    if params.blank?
      add_message :error, "Internal error, try again"
    end
  end

  def init
    self.selected_user = User.find_by(mobile_number: params[:mobile_number])
  end

  def validate
    unless params[:otp].present?
      add_message :error, "Please enter your OTP for validation"
      return
    end
    unless selected_user
      add_message :error, "Mobile number does not exist"
      return
    end
    unless selected_user.otp == params[:otp]
      add_message :error, "Wrong OTP entered. Please enter the OTP sent to your mobile number"
    end
  end

  def authorize

  end

  def process
    # skipping validations because users from the mobile number invite flow won't have their details filled in yet
    selected_user.assign_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
    selected_user.save(validate: false)
  end

  def success
    Login::VerifyLoginOtp::OtpPresenter.new(user, params, messages)
  end

  class User::Login::VerifyLoginOtp::OtpPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :mobile_number

    def init

      self.mobile_number = params[:mobile_number]
    end

  end
end