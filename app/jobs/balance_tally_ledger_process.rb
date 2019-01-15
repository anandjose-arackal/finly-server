class BalanceTallyLedgerProcess < ActiveJob::Base

  attr_accessor :company

  def perform
    # this will update the balance for today's date on the two balances
    relevant_companies = Company.all.joins(:feature_subscription).where('feature_subscriptions.current_account_connected IN (?)', [false, nil])
    company_balance = YesBankCompanyAccount.with_company_id(relevant_companies.pluck(:id)).joins(:balance).sum(:value)
    users = User.with_company_id(relevant_companies.pluck(:id))
    wallet_balance = VendorPaymentWallet.with_user_id(users.pluck(:id)).joins(:balance).sum(:value)
    self.company = Company.first
    api_balance = yes_bank_balance
    db_balance = company_balance + wallet_balance

    previous_ledger = BalanceTallyLedger.reorder(created_at: :desc).first
    previous_balance = previous_ledger&.api_balance&.value.to_f

    previous_timestamp = previous_ledger&.created_at
    sum_of_successful_payments = Payment.where(receiving_account_type: "BankAccount").where('payments.created_at >= ? AND payments.created_at <= ?', previous_timestamp, DateUtils.local_date_time).with_payment_status([PaymentStatus.id_for(:completed), PaymentStatus.id_for(:processing)]).joins(:amount).sum(:value)

    calculated_balance = previous_balance + sum_of_successful_payments

    btl = BalanceTallyLedger.create(date: DateUtils.local_date, api_balance_attributes: {value: api_balance, currency_id: Currency.first.id}, finly_database_balance_attributes: {value: (company_balance + wallet_balance), currency_id: Currency.first.id}, calculated_balance_attributes: {value: calculated_balance, currency_id: Currency.first.id})

    # trigger mailer if the difference in balance is difference from the sum of payments for today
    if (previous_balance + sum_of_successful_payments) <= api_balance
      # send mailer
      Event::EAlert::Create.(nil, title: 'DB Balance less than API balance', description: "DB Balance Less than API Balance. \n DB Balance: #{db_balance} \n Calculated Balance: #{calculated_balance} \n API Balance: #{api_balance}", subject: 'Balance Mismatch between DB and API')
    end
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