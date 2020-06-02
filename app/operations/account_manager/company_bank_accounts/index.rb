# Returns all bank accounts for a company

# Parameters Required
# 1. user
# 2. options
#   a. balance(optional) : returns balance w/ all bank accounts
#

class AccountManager::CompanyBankAccounts::Index < AccountManager::CompanyBankAccounts::Base

  attr_accessor :bank_accounts, :balance_requested

  def authorized_user_types
    [:vendor_payments_admin, :vendor_payments_creditor]
  end

  def init
    self.bank_accounts = []
    self.balance_requested = params[:balance]
  end

  def process
    # This is considering companies will only have one bank account in each of the below banks
    all_bank_accounts = [
      {account: user.company.yes_bank_company_account},
      {account: user.company.icici_bank_company_account},
      {account: user.company.kotak_bank_company_account},
      {account: user.company.utility_bills_account}
    ]

    all_bank_accounts.each do |bank_account|
      if bank_account[:account].present? && bank_account[:account].enabled
        account_data = {
            name: bank_account[:account].class.model_name.human,
            type: bank_account[:account].class.name,
            id: bank_account[:account].id
        }

        if self.balance_requested
          if bank_account[:account].class.name == 'KotakBankCompanyAccount'
            # todo - kotak : Sending text as balance api is not there | instead of showing 9999999999 its gonna display the test on frontend
            account_data[:balance] = 'Not Available'
          else
            account_data[:balance] = retrieve_balance(bank_account[:account])
          end
        end

        self.bank_accounts.push(account_data)
      end
    end
  end

  def success
    params[:bank_accounts] = self.bank_accounts
    AccountManager::CompanyBankAccounts::Index::Presenter.new(user, params, messages)
  end

  class AccountManager::CompanyBankAccounts::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :bank_accounts

    def init
      self.bank_accounts = params[:bank_accounts]
    end
  end

  private

  def retrieve_balance(account)
    return 0 unless account.present? and account.enabled

    case account.class.name
    when "YesBankCompanyAccount"
      adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
    when "IciciBankCompanyAccount"
      adapter = AccountManager::IciciBankAccount::IciciBankCompanyAccountAdapter.new(user.company.icici_bank_company_account)
    when "KotakBankCompanyAccount"
      adapter = AccountManager::KotakBankAccount::KotakBankCompanyAccountAdapter.new(user.company.kotak_bank_company_account)
    when "UtilityBillsAccount"
      adapter = AccountManager::BillingAccount::UtilityBillsAccountAdapter.new(user.company.utility_bills_account)
    else
      adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
    end

    adapter.balance
  end
end