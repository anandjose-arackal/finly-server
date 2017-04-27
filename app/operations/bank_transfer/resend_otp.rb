class BankTransfer::ResendOtp < BaseOperation

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    otp_type = params&.dig(:otp_type)
    unless otp_type.present?
      add_message :error, 'OTP Type not found'
      return
    end
    unless ['enable', 'beneficiary_add'].include?(otp_type)
      add_message :error, 'Invalid Resend OTP Type'
      return
    end
  end

  def process
    result = nil
    case params&.dig(:otp_type)
      when 'enable'
        result = ItzCash::Dmt::Otp::Resend.(user, type: ItzCash::Dmt::Otp::Resend::TYPE[:sender_registration])
      when 'beneficiary_add'
        result = ItzCash::Dmt::Otp::Resend.(user, type: ItzCash::Dmt::Otp::Resend::TYPE[:beneficiary_registration])
    end
    unless result.success?
      add_message :error, result&.messages[:error]
    end
  end

end