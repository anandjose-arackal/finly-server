class Company::Balances::SetBalances < BaseOperation

  attr_accessor :company, :company_admin, :update_params

  def initialize(company, params)
    self.company = company
    self.params = params
  end

  def pre_validate
    if company.blank? || params.blank?
      add_message :errors, "Invalid parameters"
      return
    end
  end

  def init

  end

  def process
    self.update_params = extract_balance_params(company)
    if company.company_balance_histories.find_by(date: params[:date]).present?
      balance_history = company.company_balance_histories.find_by(date: params[:date])
      unless balance_history.update(update_params)
        add_message :error, balance_history.errors.full_messages
      end
    else
      balance_history = CompanyBalanceHistory.new(update_params)
      # no question of error messages as this is a background task
      unless balance_history.save
        add_message :error, balance_history.errors.full_messages
      end
    end
  end

  private

  def extract_balance_params(company)
    neft_balance_op = Company::Transaction::Show.(company, {start_date: Date.today, end_date: Date.today})
    neft_transfer_total =  neft_balance_op.transactions.manual_fund_credits.with_date(params[:date]).joins(:transaction_amount).sum(:value) rescue 0

    self.company_admin = company.users.only_admins.first
    current_company_balance = Company::VirtualAccount::Balance.(company_admin).balance rescue 0
    company_withdrawal_to_card = 0
    company_withdrawal_to_wallet = 0
    company_load_from_card = 0
    company_load_from_wallet = 0
    card_withdrawal_to_virtual_account = 0
    card_withdrawal_to_wallet = 0
    card_withdrawal_to_card = 0
    card_load_from_card = 0
    card_load_from_wallet = 0
    card_load_from_virtual_account = 0
    card_balance_total = 0
    wallet_balance_total = 0
    wallet_withdrawal_to_virtual_account = 0
    wallet_withdrawal_to_wallet = 0
    wallet_withdrawal_to_card = 0
    wallet_load_from_virtual_account = 0
    wallet_load_from_card = 0
    wallet_load_from_wallet = 0

    card_expenses_total = 0
    card_atm_withdrawals = 0

    cash_on_hand_total = 0
    cash_on_hand_load_total = 0
    cash_on_hand_withdrawal_total = 0

    company.users.each do |user|

      company_withdrawal_to_card += user.receiving_payments.with_date(params[:date]).credit_from_virtual_account_to_card.joins(:amount).sum(:value)
      company_withdrawal_to_wallet += user.receiving_payments.with_date(params[:date]).credit_from_virtual_account_to_wallet.joins(:amount).sum(:value)

      company_load_from_card += user.initiating_payments.with_date(params[:date]).debit_from_card_to_virtual_account.joins(:amount).sum(:value)
      company_load_from_wallet += user.initiating_payments.with_date(params[:date]).debit_from_wallet_to_virtual_account.joins(:amount).sum(:value)

      card_withdrawal_to_virtual_account += user.receiving_payments.with_date(params[:date]).debit_from_card_to_virtual_account.joins(:amount).sum(:value)
      card_withdrawal_to_wallet += user.receiving_payments.with_date(params[:date]).debit_from_card_to_wallet.joins(:amount).sum(:value)
      card_withdrawal_to_card += user.receiving_payments.with_date(params[:date]).debit_from_card_to_card.joins(:amount).sum(:value)

      card_load_from_wallet += user.receiving_payments.with_date(params[:date]).credit_from_wallet_to_card.joins(:amount).sum(:value)
      card_load_from_card += user.receiving_payments.with_date(params[:date]).credit_from_card_to_card.joins(:amount).sum(:value)
      card_load_from_virtual_account += user.receiving_payments.with_date(params[:date]).credit_from_virtual_account_to_card.joins(:amount).sum(:value)

      card_balance_total += user.cards.first.card_balance_value rescue 0

      wallet_withdrawal_to_virtual_account += user.receiving_payments.with_date(params[:date]).debit_from_wallet_to_virtual_account.joins(:amount).sum(:value)
      wallet_withdrawal_to_card += user.receiving_payments.with_date(params[:date]).debit_from_wallet_to_card.joins(:amount).sum(:value)
      wallet_withdrawal_to_wallet += user.receiving_payments.with_date(params[:date]).debit_from_wallet_to_wallet.joins(:amount).sum(:value)

      wallet_load_from_virtual_account += user.receiving_payments.with_date(params[:date]).credit_from_virtual_account_to_wallet.joins(:amount).sum(:value)
      wallet_load_from_wallet += user.receiving_payments.with_date(params[:date]).credit_from_card_to_wallet.joins(:amount).sum(:value)
      wallet_load_from_card += user.receiving_payments.with_date(params[:date]).credit_from_wallet_to_wallet.joins(:amount).sum(:value)

      wallet_balance_total += user.wallet.balance_value

      card_expenses_total += user.expenses.only_card_expenses.with_date(params[:date]).joins(:amount).sum(:value)
      card_atm_withdrawals += user.card_transactions.on_date(params[:date]).atm_withdrawals.joins(:billing_amount).sum(:value)

      cash_on_hand_total += user.cash_in_hand.value rescue 0
      cash_on_hand_load_total += user.receiving_payments.with_date(params[:date]).cash_on_hand_additions.joins(:amount).sum(:value)
      cash_on_hand_withdrawal_total += user.receiving_payments.with_date(params[:date]).cash_on_hand_deductions.joins(:amount).sum(:value)

    end

    {
      company_id: company.id,
      date: (params[:date]),
      neft_transfer_attributes: {value: neft_transfer_total, currency_id: Currency.first.id},
      company_balance_attributes: {value: current_company_balance, currency_id: Currency.first.id},
      company_withdrawal_to_card_attributes: {value: company_withdrawal_to_card, currency_id: Currency.first.id},
      company_withdrawal_to_wallet_attributes: {value: company_withdrawal_to_wallet, currency: Currency.first},
      company_load_from_card_attributes: {value: company_load_from_card, currency: Currency.first},
      company_load_from_wallet_attributes: {value: company_load_from_wallet, currency: Currency.first},
      card_withdrawal_to_virtual_account_attributes: {value: card_withdrawal_to_virtual_account, currency: Currency.first},
      card_withdrawal_to_card_attributes: {value: card_withdrawal_to_card, currency: Currency.first},
      card_withdrawal_to_wallet_attributes: {value: card_withdrawal_to_wallet, currency: Currency.first},
      card_load_from_virtual_account_attributes: {value: card_load_from_virtual_account, currency: Currency.first},
      card_load_from_card_attributes: {value: card_load_from_card, currency: Currency.first},
      card_load_from_wallet_attributes: {value: card_load_from_wallet, currency: Currency.first},
      card_balance_attributes: {value: card_balance_total, currency: Currency.first},
      wallet_load_from_card_attributes: {value: wallet_load_from_card, currency: Currency.first},
      wallet_load_from_virtual_account_attributes: {value: wallet_load_from_virtual_account, currency: Currency.first},
      wallet_load_from_wallet_attributes: {value: wallet_load_from_wallet, currency: Currency.first},
      wallet_withdrawal_to_card_attributes: {value: wallet_withdrawal_to_card, currency: Currency.first},
      wallet_withdrawal_to_virtual_account_attributes: {value: wallet_withdrawal_to_virtual_account, currency: Currency.first},
      wallet_withdrawal_to_wallet_attributes: {value: wallet_withdrawal_to_wallet, currency: Currency.first},
      wallet_balance_attributes: {value: wallet_balance_total, currency: Currency.first},
      card_expenses_attributes: {value: card_expenses_total, currency: Currency.first},
      card_atm_withdrawal_attributes: {value: card_atm_withdrawals, currency: Currency.first},
      cash_on_hand_balance_attributes: {value: cash_on_hand_total, currency: Currency.first},
      cash_on_hand_withdrawal_attributes: {value: cash_on_hand_withdrawal_total, currency: Currency.first},
      cash_on_hand_load_attributes: {value: cash_on_hand_load_total, currency: Currency.first}
    }

  end

end
