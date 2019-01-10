class BalanceTallyLedgerProcess < ActiveJob::Base

  attr_accessor :company

  def perform
    # this will update the balance for today's date on the two balances
    relevant_companies = Company.all.joins(:feature_subscription).where('feature_subscriptions.current_account_connected IN (?)', [false, nil])
    company_balance = YesBankCompanyAccount.with_company_id(relevant_companies.pluck(:id)).joins(:balance).sum(:value)
    users = User.with_company_id(relevant_companies.pluck(:id))
    wallet_balance = VendorPaymentWallet.with_user_id(users.pluck(id)).joins(:balance).sum(:value)
    self.company = Company.first
    api_balance= yes_bank_balance
    BalanceTallyLedger.create(date: DateUtils.local_date, api_balance_attributes: {value: api_balance, currency_id: Currency.first}, finly_database_balance_attributes: {value: (company_balance + wallet_balance), currency_id: Currency.first.id})
  end

  def yes_bank_balance
    handle = self.object_id
    YesBankBalanceProvider.perform_async(handle, self.company.id)
    timeout = 30
    begin
      Timeout.timeout(timeout) do
        loop do
          result = Resque.reserve(handle)
          next if result.blank?
          args = result.args.first
          success = args['success']
          message = args['message']
          return 0 unless success
          balance = args['balance']
          payment_order = options[:payment_order]
          blocked_amount_for_payments = account.blocked_amount_for_pending_payments(payment_order&.id)
          return (balance - blocked_amount_for_payments)
        end
      end
    rescue Timeout::Error
      return 0
    end
  end
end