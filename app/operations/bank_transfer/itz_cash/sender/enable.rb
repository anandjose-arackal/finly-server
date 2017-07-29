class BankTransfer::Sender::Enable < BankTransfer::Sender::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def validate
    if user.itz_cash_dmt_sender&.otp_verified
      add_message :error, 'You have already enabled Bank Transfers'
      return
    end
  end

  def process
    if user.itz_cash_dmt_sender.blank?
      # Register for DMT
      result = ItzCash::Dmt::Sender::Register.(user)
      unless result.success?
        add_message :error, result.messages[:error]
      end
    else
      # Resend OTP
      result = ItzCash::Dmt::Otp::Resend.(user, type: ItzCash::Dmt::Otp::Resend::TYPE[:sender_registration])
      unless result.success?
        add_message :error, result.messages[:error]
      end
    end
  end

end