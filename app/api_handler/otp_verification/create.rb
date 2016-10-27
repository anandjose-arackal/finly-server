class OtpVerification::Create < OtpVerification::Base
  attr_accessor :mobile_number, :status, :code, :otp

  def env_key
    'msg91_generate_otp'
  end

  def pre_validate
    if params.blank? or params[:mobile_number].blank?
      add_message :error, 'Mobile number cannot be blank'
    end
  end

  def process
    # post payload as JSON instead of "www-form-urlencoded" encoding:
    self.response = self.connection.post do |req|
      req.url path
      req.headers['application-Key'] = '-C4-IpmaywMnqaBzehqSZiP2aznU6_onhpjfiFDnxAPZBcXH-f_6JT_4fH-Qx1Y54tPjvXuShhZkCwjmroxXa7hV1dQgYede4fqAltJYivA8Cia1IvrW0FzsNaUAUFCyTXDHO1IV5-Q63zwNbzxTFw=='
      req.body = "{ 'countryCode': '91', 'mobileNumber': '#{params[:mobile_number]}', 'getGeneratedOTP': true }"
    end
  end

  def parse
    json_response = JSON.parse(self.response.body) rescue nil
    add_message :error, 'Error generating OTP' if json_response.blank?
    self.status = json_response['status'] rescue nil
    self.code = json_response['response']['code'] rescue nil
    self.otp = json_response['response']['oneTimePassword'] rescue nil
    add_message :error, 'Error generating OTP' if self.status.blank? or not self.status == 'success' or self.code.blank? or
        not self.code == 'OTP_SENT_SUCCESSFULLY' or self.otp.blank?
  end

  def success
    OtpVerification::Create::SuccessPresenter.new(user, status: self.status, code: self.code, otp: self.otp, mobile_number: self.mobile_number)
  end

  class OtpVerification::Create::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :status, :code, :otp, :mobile_number

    def init
      self.status = params[:status]
      self.code = params[:code]
      self.otp = params[:otp]
      self.mobile_number = params[:mobile_number]
    end

  end

end