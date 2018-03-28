class Invoicing::Company::CreditsWithdrawal::Show < Invoicing::Company::Base

  attr_accessor :collect_credit_account, :company_balance_adapter, :balance

  class Invoicing::Company::CreditsWithdrawal::Show::CollectCreditAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :collect_credit_account, :balance

    def init
      self.collect_credit_account = params[:collect_credit_account]
      self.balance = params[:balance]
    end
  end

  def init
    self.collect_credit_account = user.company.collect_credit_account
    self.company_balance_adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
  end

  def validate
    if self.collect_credit_account.blank?
      add_message :error, "Current account details not found"
      return
    end
  end

  def process
    self.balance = self.company_balance_adapter.balance
  end

  def success
    params[:balance] = self.balance
    params[:collect_credit_account] = self.collect_credit_account
    Invoicing::Company::CreditsWithdrawal::Show::CollectCreditAccountPresenter.new(user, params, messages)
  end
end