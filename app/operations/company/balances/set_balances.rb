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
    transfers_to_company_account = 0
    transfers_from_company_account = 0
    company_cards_balance = 0
    company_cards_withdrawal = 0
    company_cards_load = 0
    company_finly_money_balance = 0
    company_finly_money_load = 0
    company_finly_money_withdrawal = 0

    company.users.only_admins.each do |user|
      # summing all transfers from company account
      transfers_to_company_account += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_card_to_virtual_account),
                                                                                                                  PaymentType.id_for(:debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
      # summing all the transfers from company account to card or wallet
      transfers_from_company_account += user.initiating_payments.where(date: params[:date]).where([payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_wallet),
                                                                                                                     PaymentType.id_for(:credit_from_virtual_account_to_card)]]).joins(:amount).sum(:value)

      # summing card loads across the company
      company_cards_load += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_card)]).joins(:amount).sum(:value)

      # summing up card withdrawals across the company
      company_cards_withdrawal += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_card_to_virtual_account)]).joins(:amount).sum(:value)

      # summing up wallet loads across the company
      company_finly_money_load += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_wallet)]).joins(:amount).sum(:value)

      # summing up wallet withdrawals across the approves_to_name
      company_finly_money_withdrawal += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
    end

    company.users.only_finance_managers.each do |user|
      # summing card loads across the company
      company_cards_load += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card)]).joins(:amount).sum(:value)

      # summing up card withdrawals across the company
      company_cards_withdrawal += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_card_to_wallet)]).joins(:amount).sum(:value)

      # summing up wallet loads across the company
      company_finly_money_load += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_wallet)]).joins(:amount).sum(:value)

      # summing up wallet withdrawals across the approves_to_name
      company_finly_money_withdrawal += user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_wallet)]).joins(:amount).sum(:value)
    end

    # now summing the card and finly money balances for all users
    company.users.each do |user|
      company_cards_balance += user.cards.first.card_balance_value
      company_finly_money_balance += user.wallet.balance_value
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
