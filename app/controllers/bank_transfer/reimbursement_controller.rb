class BankTransfer::ReimbursementController < ApplicationController


  before_action :doorkeeper_authorize!

  def create
    action_type = params&.dig(:action_type)
    unless action_type
      respond response: :failure, message: 'Action not found'
      return
    end
    case action_type
      when 'request_otp'
        @result = BankTransfer::Reimbursement::Beneficiary::RequestOtp.(current_user, params)
      when 'verify_otp'
        @result = BankTransfer::Reimbursement::Beneficiary::VerifyOtp.(current_user, params)
      when 'add'
        @result = BankTransfer::Reimbursement::Beneficiary::Add.(current_user, params)
    end
    if @result&.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def show
    @result = BankTransfer::Reimbursement::Show.(current_user, params)
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
        @result = BankTransfer::Sender::Enable.(current_user, params)
      when 'enable_verify_otp'
        @result = BankTransfer::Sender::VerifyOtp.(current_user, params)
      when 'set_default'
        @result = BankTransfer::Reimbursement::Beneficiary::SetDefault.(current_user, params)
      when 'resend_otp'
        @result = BankTransfer::ResendOtp.(current_user, params)
      when 'request_otp'
        @result = BankTransfer::Reimbursement::Beneficiary::RequestOtp.(current_user, params)
      when 'verify_otp'
        @result = BankTransfer::Reimbursement::Beneficiary::VerifyOtp.(current_user, params)
      when 'add'
        @result = BankTransfer::Reimbursement::Beneficiary::Add.(current_user, params)
    end
    if @result&.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

end
