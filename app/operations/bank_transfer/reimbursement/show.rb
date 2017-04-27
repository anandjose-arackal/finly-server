class BankTransfer::Reimbursement::Show < BankTransfer::Reimbursement::Base
  attr_accessor :reimbursement_accounts, :enabled

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def process
    self.enabled = !!user.itz_cash_dmt_sender&.otp_verified
    self.reimbursement_accounts = user.itz_cash_dmt_sender&.beneficiaries&.reimbursement_accounts
  end

  def success
    params[:enabled] = self.enabled
    params[:reimbursement_accounts] = self.reimbursement_accounts
    BankTransfer::Reimbursement::Show::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::Reimbursement::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reimbursement_accounts, :enabled, :mobile_number

    def init
      self.mobile_number = user.mobile_number
      self.enabled = params[:enabled]
      self.reimbursement_accounts = params[:reimbursement_accounts]
    end

  end

end