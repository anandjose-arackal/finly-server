class BankTransfer::Users::GetManagers < BankTransfer::Users::Base

  attr_accessor :reviewers, :creditors

  def authorized_user_types
    [:vendor_payments_admin, :company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def process
    self.reviewers = user.company.users.only_vendor_payment_reviewers
    self.creditors = user.company.users.only_vendor_payment_creditors
  end

  def success
    params[:reviewers] = self.reviewers
    params[:creditors] = self.creditors
    BankTransfer::Users::GetManagers::ManagersPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::GetManagers::ManagersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :reviewers, :creditors, :company_id

    def init
      self.reviewers = params[:reviewers]
      self.creditors = params[:creditors]
      self.company_id = user.company_id
    end
  end

end