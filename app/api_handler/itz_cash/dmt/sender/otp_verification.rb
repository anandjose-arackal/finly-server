require 'securerandom'
class ItzCash::Dmt::Sender::OtpVerification < ItzCash::Dmt::Base
  attr_accessor :password

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.itz_cash_dmt_sender.blank?
      add_message :error, 'Registration not found'
      return
    end
    if params.blank? or params[:otp].blank?
      add_message :error, 'Please enter the OTP received on your mobile phone to complete the registration'
    end
  end

  def request_type
    201
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/dmt/sender/otp_verification.xml.erb"
  end

  def query_xml_params
    self.password = (user.itz_cash_dmt_sender.password or SecureRandom.hex(13))
    {
        username: user.itz_cash_dmt_sender.username,
        icw_code: Constants::ItzCash::ICW_CODE,
        mobile_number: user.mobile_number,
        registration_id: user.itz_cash_dmt_sender.registration_id,
        otp: params[:otp],
        password: self.password,
        wallet_id: Constants::ItzCash::EASY_WALLET_ID,
        wallet_type: Constants::ItzCash::EASY_WALLET_TYPE
    }
  end

  def success
    update_password
    super
  end

  protected
  def update_password
    user.itz_cash_dmt_sender.update(password: self.password)
  end

end