# this operation will take a payment order id and return whether the particular order can
# be processed at the current time or not - can return a flag, or the actual timings as well

class BankTransfer::Configuration::TransferTimings < BankTransfer::Configuration::Base

  attr_accessor :timings, :payment_order, :payment_request, :payment_mode, :date, :bank_accounts

  class BankTransfer::Configuration::TransferTimings::TimingsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :timings, :allowed, :next_valid_date, :bank_accounts

    def init
      self.allowed = params[:allowed]
      self.timings = params[:timings]
      self.next_valid_date = params[:next_date]
      self.bank_accounts = params[:bank_accounts]

    end

  end

  def pre_validate
  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    if id.present?
      init_bank_payment_request(id)
    else
      self.payment_mode = params[:payment_mode]
      self.date = params[:date]
    end

    self.bank_accounts = []
  end

  def validate
    id = params[:id] || params[:bank_payment_request_id]
    if id.present? and self.payment_request.blank? and self.payment_order.blank?
      add_message :error, 'Payment order not found'
      return
    end
    if self.payment_mode.blank?
      add_message :error, 'Payment mode cannot be blank'
      return
    end
  end

  def process
    kotak_bank_company_account = user.company.kotak_bank_company_account
    yes_bank_company_account = user.company.yes_bank_company_account
    icici_bank_company_account = user.company.icici_bank_company_account

    if kotak_bank_company_account.present? && kotak_bank_company_account.enabled
      account_data = {
          name: kotak_bank_company_account.class.model_name.human,
          type: kotak_bank_company_account.class.name,
          id: kotak_bank_company_account.id,
          # balance: retrieve_balance(kotak_bank_company_account)
          balance: "Not Available" # todo - kotak : Sending text as balance api is not there | instead of showing 9999999999 its gonna dispaly the test on frontend
      }

      self.bank_accounts.push(account_data)
    end

    if yes_bank_company_account.present? && yes_bank_company_account.enabled
      account_data = {
          name: yes_bank_company_account.class.model_name.human,
          type: yes_bank_company_account.class.name,
          id: yes_bank_company_account.id,
          balance: retrieve_balance(yes_bank_company_account)
      }

      self.bank_accounts.push(account_data)
    end

    if icici_bank_company_account.present? && icici_bank_company_account.enabled
      account_data = {
          name: icici_bank_company_account.class.model_name.human,
          type: icici_bank_company_account.class.name,
          id: icici_bank_company_account.id,
          balance: retrieve_balance(icici_bank_company_account)
      }
      self.bank_accounts.push(account_data)
    end
  end

  def success
    params[:allowed] = TransferTimingUtils.within_timeframe?(self.payment_mode, self.date)
    params[:next_date] = TransferTimingUtils.next_valid_date(self.date, self.payment_mode)
    params[:bank_accounts] = self.bank_accounts
    BankTransfer::Configuration::TransferTimings::TimingsPresenter.new(user, params, messages)
  end

  def retrieve_balance(account)
    return 0 unless account.present?

    case account.class.name
    when "YesBankCompanyAccount"
      adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
    when "IciciBankCompanyAccount"
      adapter = AccountManager::IciciBankAccount::IciciBankCompanyAccountAdapter.new(user.company.icici_bank_company_account)
    when "KotakBankCompanyAccount"
      adapter = AccountManager::KotakBankAccount::KotakBankCompanyAccountAdapter.new(user.company.kotak_bank_company_account)
    else
      adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
    end

    adapter.balance
  end

  protected

  def init_bank_payment_request(id)
    self.payment_request = BankPaymentRequest.find_by(id: id)
    self.payment_order = payment_request&.payment_order
    self.date = payment_order&.scheduled_at
    self.payment_mode = payment_order&.payment_mode
  end

end