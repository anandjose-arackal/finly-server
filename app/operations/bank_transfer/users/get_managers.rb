class BankTransfer::Users::GetManagers < BankTransfer::Users::Base

  attr_accessor :managers, :finance_managers

  def authorized_user_types
    [:vendor_payment_admin, :company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def process
    self.managers = user.company.users.only_vendor_payment_admins
    self.finance_managers = user.company.users.only_vendor_payment_creditors
  end

  def success
    params[:managers] = self.managers
    params[:finance_managers] = self.finance_managers
    BankTransfer::Users::GetManagers::ManagersPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::GetManagers::ManagersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :managers, :finance_managers

    def init
      self.managers = params[:managers]
      self.finance_managers = params[:finance_managers]
    end
  end

end