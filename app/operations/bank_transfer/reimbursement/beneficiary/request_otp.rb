class BankTransfer::Reimbursement::Beneficiary::RequestOtp < BankTransfer::Reimbursement::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def process
    result = ItzCash::Dmt::Beneficiary::Register.(user)
    unless result.success?
      add_message :error, result.messages[:error]
    end
  end

end