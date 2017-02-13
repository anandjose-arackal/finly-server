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
    result = Company::VirtualAccount::Balance.(user)
    items[:company_account_closing_balance] = result.balance

    items[:company_account_details] = {}
    items[:total_account_load_via_NEFT] = 0

    items[:company_account_details][:loads] = []

    company.fund_load_requests.where('date >= ? AND date <= ?', start_date, end_date).each do |transfer|
      items[:company_account_details][:loads] << {date: transfer.date, amount: transfer.amount_value}
      items[:total_account_load_via_NEFT] += transfer.amount_value
    end

    items[:transfers_to_company_account] = {}
    items[:transfers_to_company_account][:total] = 0
    items[:transfers_to_company_account][:admin_transfers] = []
    items[:transfers_from_company_account] = {}
    items[:transfers_from_company_account][:total] = 0
    items[:transfers_from_company_account][:admin_transfers] = []
    company.users.only_admins.each do |user|
      to_account_total = user.initiating_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:debit_from_card_to_virtual_account),
                                                                                                                                 PaymentType.id_for(:debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
      items[:transfers_to_company_account][:total] += to_account_total
      items[:transfers_to_company_account][:admin_transfers] << {name: user.name, amount: precision_value(to_account_total)}

      from_account_total = user.initiating_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_card),
                                                                                                                                   PaymentType.id_for(:credit_from_virtual_account_to_wallet)]).joins(:amount).sum(:value)
      items[:transfers_from_company_account][:total] += from_account_total
      items[:transfers_from_company_account][:admin_transfers] << {name: user.name, amount: precision_value(from_account_total)}
    end

    items[:total_amount_transferred] = {}
    items[:total_amount_transferred][:to_finly_cards] = 0
    items[:total_amount_transferred][:to_finly_money] = 0
    company.users.each do |user|
      card_total = user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_card)]).joins(:amount).sum(:value)
      items[:total_amount_transferred][:to_finly_cards] += card_total

      finly_money_total = user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_wallet)]).joins(:amount).sum(:value)
      items[:total_amount_transferred][:to_finly_money] += finly_money_total
    end

    items[:company_account_opening_balance] = items[:company_account_closing_balance] + items[:transfers_to_company_account][:total] - items[:transfers_from_company_account][:total]
  end

  def success
    params[:items] = items
    Company::Statement::TransactionsSummary::SummaryPresenter.new(user, params, messages)
  end

  class Company::Statement::TransactionsSummary::SummaryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :items

    def init
      self.items = params[:items]
    end
  end

end