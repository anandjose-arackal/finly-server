class Company::Statement::TransactionsSummary < Company::Statement::Base

  attr_accessor :items

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    super()
    self.items = {}
    self.company = user.company
  end

  def validate

  end

  def authorize

  end

  def process
    if end_date.to_date == Date.today
      result = Company::VirtualAccount::Balance.(user)
      items[:company_account_closing_balance] = result.balance rescue 0
    else
      items[:company_account_closing_balance] = company.company_balance_histories.find_by(date: end_date.to_date).company_balance.value rescue 0
    end

    items[:company_account_details] = {}
    items[:total_account_load_via_NEFT] = 0

    items[:company_account_details][:loads] = []

    company.company_transactions.with_date_range(start_date, end_date).each do |transfer|
      items[:company_account_details][:loads] << {date: transfer.transaction_date.to_date, amount: transfer.transaction_amount_value}
      items[:total_account_load_via_NEFT] += transfer.transaction_amount_value
    end

    items[:transfers_to_company_account] = {}
    items[:transfers_to_company_account][:total] = 0
    items[:transfers_to_company_account][:admin_transfers] = []
    items[:transfers_from_company_account] = {}
    items[:transfers_from_company_account][:total] = 0
    items[:transfers_from_company_account][:admin_transfers] = []
    company.users.only_admins.each do |user|
      to_account_total = user.initiating_payments.with_date_range(start_date, end_date).debit_to_virtual_account.joins(:amount).sum(:value)
      items[:transfers_to_company_account][:total] += to_account_total
      items[:transfers_to_company_account][:admin_transfers] << {name: user.name, amount: precision_value(to_account_total)}

      from_account_total = user.initiating_payments.with_date_range(start_date, end_date).credit_from_virtual_account.joins(:amount).sum(:value)
      items[:transfers_from_company_account][:total] += from_account_total
      items[:transfers_from_company_account][:admin_transfers] << {name: user.name, amount: precision_value(from_account_total)}
    end

    items[:total_amount_transferred] = {}
    items[:total_amount_transferred][:to_finly_cards] = 0
    items[:total_amount_transferred][:to_finly_money] = 0
    items[:total_amount_transferred][:from_finly_cards] = 0
    items[:total_amount_transferred][:from_finly_money] = 0
    company.users.each do |user|
      to_card_total = user.receiving_payments.with_date_range(start_date, end_date).credit_from_virtual_account_to_card.joins(:amount).sum(:value)
      items[:total_amount_transferred][:to_finly_cards] += to_card_total

      from_card_total = user.receiving_payments.with_date_range(start_date, end_date).debit_from_card_to_virtual_account.joins(:amount).sum(:value)
      items[:total_amount_transferred][:from_finly_cards] += from_card_total

      from_finly_money_total = user.receiving_payments.with_date_range(start_date, end_date).debit_from_wallet_to_virtual_account.joins(:amount).sum(:value)
      items[:total_amount_transferred][:from_finly_money] += from_finly_money_total

      to_finly_money_total = user.receiving_payments.with_date_range(start_date, end_date).credit_from_virtual_account_to_wallet.joins(:amount).sum(:value)
      items[:total_amount_transferred][:to_finly_money] += to_finly_money_total
    end
    
    items[:company_account_opening_balance] = company.company_balance_histories.find_by(date: start_date.to_date).company_balance.value rescue 0
  end

  def success
    params[:invalid_date] = date_before_limit?
    params[:items] = items
    Company::Statement::TransactionsSummary::SummaryPresenter.new(user, params, messages)
  end

  class Company::Statement::TransactionsSummary::SummaryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :items, :invalid_date

    def init
      self.items = params[:items]
      self.invalid_date = params[:invalid_date]
    end
  end

  private

  def date_before_limit?
    if start_date.to_date < Date.parse(Constants::BEGINNING_OF_TIME)
      return true
    end
    if end_date.to_date < Date.parse(Constants::BEGINNING_OF_TIME)
      return true
    end
    false
  end

end