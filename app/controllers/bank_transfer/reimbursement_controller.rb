class BankTransfer::ReimbursementController < BaseControllers::WebBase



  def create
    action_type = params&.dig(:action_type)
    unless action_type
      respond response: :failure, message: 'Action not found'
      return
    end
    case action_type
      when 'request_otp'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::RequestOtp.(current_user, params)
      when 'verify_otp'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::VerifyOtp.(current_user, params)
      when 'add'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::Add.(current_user, params)
    end
    if @result&.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def show
    @result = BankTransfer::ItzCash::Reimbursement::Show.(current_user, params)
    respond
  end

  def update
    action_type = params&.dig(:action_type)
    unless action_type
      respond response: :failure, message: 'Action not found'
      return
    end
    case action_type
      when 'enable'
        @result = BankTransfer::ItzCash::Sender::Enable.(current_user, params)
      when 'enable_verify_otp'
        @result = BankTransfer::ItzCash::Sender::VerifyOtp.(current_user, params)
      when 'set_default'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::SetDefault.(current_user, params)
      when 'resend_otp'
        @result = BankTransfer::ItzCash::ResendOtp.(current_user, params)
      when 'request_otp'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::RequestOtp.(current_user, params)
      when 'verify_otp'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::VerifyOtp.(current_user, params)
      when 'add'
        @result = BankTransfer::ItzCash::Reimbursement::Beneficiary::Add.(current_user, params)
    end
    if @result&.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

end
