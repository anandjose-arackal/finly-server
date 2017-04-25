class BankTransfer::Reimbursement::Index < BankTransfer::Reimbursement::Base
  attr_accessor :reimbursement_accounts

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def process
    self.reimbursement_accounts = user.itz_cash_dmt_sender.reimbursement_accounts
  end

  def success
    params[:reimbursement_accounts] = reimbursement_accounts
    BankTransfer::Reimbursement::Index::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::Reimbursement::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reimbursement_accounts

    def init
      self.reimbursement_accounts = params[:reimbursement_accounts]
    end

  end

end