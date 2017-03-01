class Company::Balances::SetBalances < BaseOperation

  attr_accessor :company, :company_admin

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
    params = extract_balance_params(company)
    balance_history = company.company_balance_histories.new(params)
    # no question of error messages as this is a background task
    balance_history.save
  end

  private

  def extract_balance_params(company)
    neft_transfer_total = 0

    self.company_admin = company.users.only_admins.first
    current_company_balance = Company::VirtualAccount::Balance.(company_admin)
    # summing up all withdrawals from card or wallet to company account
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

    company.users.each do |user|

      company_withdrawal_to_card += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_virtual_account_to_card)).joins(:amount).sum(:value)
      company_withdrawal_to_wallet += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_virtual_account_to_wallet)).joins(:amount).sum(:value)

      company_load_from_card += user.initiating_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_card_to_virtual_account)).joins(:amount).sum(:value)
      company_load_from_wallet += user.initiating_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_wallet_to_virtual_account)).joins(:amount).sum(:value)

      card_withdrawal_to_virtual_account += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_card_to_virtual_account)).joins(:amount).sum(:value)
      card_withdrawal_to_wallet += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_card_to_wallet)).joins(:amount).sum(:value)
      card_withdrawal_to_card += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_card_to_card)).joins(:amount).sum(:value)

      card_load_from_wallet += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_wallet_to_card)).joins(:amount).sum(:value)
      card_load_from_card += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_card_to_card)).joins(:amount).sum(:value)
      card_load_from_virtual_account += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_virtual_account_to_card)).joins(:amount).sum(:value)

      card_balance_total += user.cards.first.card_balance_value rescue 0

      wallet_withdrawal_to_virtual_account += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_wallet_to_virtual_account)).joins(:amount).sum(:value)
      wallet_withdrawal_to_card += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_wallet_to_card)).joins(:amount).sum(:value)
      wallet_withdrawal_to_wallet += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:debit_from_wallet_to_wallet)).joins(:amount).sum(:value)

      wallet_load_from_virtual_account += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_virtual_account_to_wallet)).joins(:amount).sum(:value)
      wallet_load_from_wallet += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_card_to_wallet)).joins(:amount).sum(:value)
      wallet_load_from_card += user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:credit_from_wallet_to_wallet)).joins(:amount).sum(:value)

      wallet_balance_total += user.wallet.balance_value

    end

    {
      company_id: company.id,
      date: params[:date],
      company_balance_attributes: {value: current_company_balance, currency: Currency.first},
      company_withdrawal_attributes: {value: transfers_from_company_account, currency: Currency.first},
      company_load_attributes: {value: transfers_to_company_account, currency: Currency.first},
      card_withdrawal_attributes: {value: company_cards_withdrawal, currency: Currency.first},
      card_load_attributes: {value: company_cards_load, currency: Currency.first},
      card_balance_attributes: {value: company_cards_balance, currency: Currency.first},
      finly_money_load_attributes: {value: company_finly_money_load, currency: Currency.first},
      finly_money_withdrawal_attributes: {value: company_finly_money_withdrawal, currency: Currency.first},
      finly_money_balance_attributes: {value: company_finly_money_balance, currency: Currency.first}
    }

  end

end
