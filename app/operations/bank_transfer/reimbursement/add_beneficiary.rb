class BankTransfer::Reimbursement::AddBeneficiary < BankTransfer::Reimbursement::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Please enter your bank details to add a Reimbursement Account'
      return
    end
    if params[:account_number].blank?
      add_message :error, 'Account Number cannot be blank'
      return
    end
    if params[:account_number_confirmation].blank?
      add_message :error, 'Account Number confirmation cannot be blank'
      return
    end
    unless params[:account_number] == params[:account_number_confirmation]
      add_message :error, 'Account Number is not matching with the Account Number Confirmation'
      return
    end
    if params[:ifsc_code].blank?
      add_message :error, 'IFSC Code cannot be blank'
      return
    end
    if user.itz_cash_dmt_sender.beneficiaries.reimbursement_accounts.with_account_number(params[:account_number]).present?
      add_message :error, 'Account has already been added as a Reimbursement Account'
    end
  end

  def process

  end

end