class BankTransfer::Reimbursement::Beneficiary::VerifyOtp < BankTransfer::Reimbursement::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:otp).blank?
      add_message :error, 'Please enter the OTP which you have received on your registered mobile number'
    end
  end

  def process
    result = ItzCash::Dmt::Beneficiary::VerifyOtp.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
    end
  end

end