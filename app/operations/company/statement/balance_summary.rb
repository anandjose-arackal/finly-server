# this operations will not have a date as it is only the current status

class Company::Statement::BalanceSummary < Company::Statement::Base

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
    self.items = {}
    self.company = user.company
  end

  def validate

  end

  def authorize

  end

  def process
    result = Company::VirtualAccount::Balance.(user)
    items[:current_company_balance] = result.balance

    # calculating money with employees in various forms
    items[:total_amount_with_employees] = {}
    items[:total_amount_with_employees][:in_cards] = 0
    items[:total_amount_with_employees][:in_finly_money] = 0
    items[:total_amount_with_employees][:in_cash_on_hand] = 0
    items[:total_amount_with_employees][:total] = 0
    company.users.each do |user|
      items[:total_amount_with_employees][:in_cards] += user.cards.first.balance_value rescue 0
      items[:total_amount_with_employees][:in_finly_money] += user.wallet.balance_value
      items[:total_amount_with_employees][:in_cash_on_hand] += user.cash_in_hand.value rescue 0
    end
    items[:total_amount_with_employees].each do |k, v|
      next if k == :total
      items[:total_amount_with_employees][:total] += v
    end

    items[:money_requests_awaiting_settlement] = {}
    items[:money_requests_awaiting_settlement][:via_card] = 0
    items[:money_requests_awaiting_settlement][:via_cash] = 0
    items[:reports_awaiting_settlement] = 0
    items[:total_cash_in_hand] = 0
    company.users.each do |user|
      # calculating advance fund totals
      user.money_requests.approved.via_card_only.each do |request|
        items[:money_requests_awaiting_settlement][:via_card] += request.total_amount
      end
      user.money_requests.approved.via_cash_only.each do |request|
        items[:money_requests_awaiting_settlement][:via_cash] += request.total_amount
      end

      # calculating pending report reimbursements - i.e. reports that are in approved state
      items[:reports_awaiting_settlement] += user.reports.approved.count
    end

    items[:unreported_expenses] = {}
    items[:unreported_expenses][:via_card_number] = 0
    items[:unreported_expenses][:via_card_total] = 0
    items[:unreported_expenses][:via_cash_number] = 0
    items[:unreported_expenses][:via_cash_total] = 0

    company.users.each do |user|
      items[:unreported_expenses][:via_card_total] += user.expenses.unreported.only_card_expenses.with_amount.sum(:value) rescue 0
      items[:unreported_expenses][:via_cash_total] += user.expenses.unreported.only_manual_expenses.with_amount.sum(:value) rescue 0
      items[:unreported_expenses][:via_card_number] += user.expenses.unreported.only_card_expenses.count 0
      items[:unreported_expenses][:via_cash_number] += user.expenses.unreported.only_manual_expenses.count 0
    end

  end

  def success
    Company::Statement::BalanceSummary::SummaryPresenter.new(user, {items: items}, messages)
  end

  class Company::Statement::BalanceSummary::SummaryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :items

    def init
      self.items = params[:items]
    end
  end

end
