class BankTransfer::Reimbursement::Beneficiary::Add < BankTransfer::Reimbursement::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Please enter your bank details to add a Reimbursement Account'
      return
    end
    if params[:bank_name].blank?
      add_message :error, 'Bank name cannot be blank'
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
    existing_beneficiary = user.itz_cash_dmt_sender.beneficiaries.with_account_number(params[:account_number])&.first
    if existing_beneficiary.present?
      existing_beneficiary.update(reimbursement: true)
    else
      param = {
          first_name: user.first_name,
          middle_name: user.middle_name,
          last_name: user.last_name,
          mobile_number: user.mobile_number,
          bank_name: params[:bank_name],
          ifsc_code: params[:ifsc_code],
          account_number: params[:account_number],
          account_number_confirmation: params[:account_number_confirmation]
      }
      result = ItzCash::Dmt::Beneficiary::Add.(user, param)
      unless result.success?
        add_message :error, result.messages[:error]
      end
    end
  end

end