class BankTransfer::Sender::VerifyOtp < BankTransfer::Sender::Base
  attr_accessor :otp

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:otp].blank?
      add_message :error, 'Please enter your OTP to enable Bank Transfers'
      return
    end
    if user.itz_cash_dmt_sender&.otp_verified
      add_message :error, 'You have already enabled Bank Transfers'
      return
    end
  end

  def init
    self.otp = params[:otp]
  end

  def process
    result = ItzCash::Dmt::Sender::OtpVerification.(user, otp: self.otp)
    unless result.success?
      add_message :error, result.messages[:error]
    end
  end

end