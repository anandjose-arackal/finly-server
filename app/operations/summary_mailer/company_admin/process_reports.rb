class SummaryMailer::CompanyAdmin::ProcessReports < BaseOperation
  attr_accessor :time_slot, :configurations

  def self.call
    self.new.run
  end

  def initialize
    super(nil, nil)
  end

  def init
    self.configurations = fetch_configurations
    # self.configurations = AdminSummaryMailConfig.all
  end

  def validate
    if self.configurations.blank?
      add_message :error, 'No user has requested for summary at this time'
      return
    end
  end

  def process
    self.configurations&.each { |config| process_configuration config }
  end

  protected
  def fetch_time_slot(datetime)
    time_slot = datetime.strftime('%H')
    if datetime.minute < 30
      time_slot += ':00'
    else
      time_slot += ':30'
    end
    time_slot
  end

  def fetch_configurations
    datetime = DateTime.now
    day_of_month = datetime.day
    day_of_week = datetime.strftime("%A")
    self.time_slot = fetch_time_slot datetime
    AdminSummaryMailConfig.configurations_for(day_of_month, day_of_week, self.time_slot).group_by_user
  end

  def process_configuration(configuration)
    start_date = get_start_date configuration
    end_date = DateTime.now
    summary = {
        d_code_enabled: configuration.user.company.d_code_enabled?,
        start_date: DateUtils.datetime_formatted(start_date),
        end_date: DateUtils.datetime_formatted(end_date)
    }
    user = configuration.user
    return unless user.company_admin?
    application = configuration.application
    options = {}
    user_presenter = User::Index.(user, view: 'admin')
    if user_presenter.success?
      options[:users] = user_presenter.team
      options[:user_ids] = user_presenter.team&.pluck(:id)
      options[:cards] = Card.with_company(user.company_id).with_user(options[:user_ids]).expense_cards
      options[:card_ids] = options[:cards]&.pluck(:id)
    end

    if user.company.d_code_enabled?
      set_company_funds_summary(summary, user, start_date, end_date)
    end
    set_company_expenses_summary(summary, user, start_date, end_date, application, options)
    unless summary.blank?
      Event::ESummary::Reports.(user, user: user, summary: summary)
    end
  end

  def get_start_date(configuration)
    from_date = nil
    period = configuration.period
    if period.day?
      from_date = DateTime.now.beginning_of_day
    elsif period.week?
      starting_day_of_week = Date.parse(configuration.starting_day_of_week).wday
      from_date = Date.today
      while from_date.wday != starting_day_of_week
        from_date -= 1
      end
    elsif period.month?
      # Get first of the current month
      from_date = (DateTime.now.beginning_of_day - (DateTime.now.mday - 1))
    end
    from_date
  end

  def set_company_funds_summary(summary, user, start_date, end_date)
    company = user.company
    account = company.itz_cash_company_account
    transactions = account.finly_transactions.with_date_range(start_date, end_date)
    transactions_summary = FinlyTransaction::Summary.(user, finly_transactions: transactions).summary
    opening_balance = account.opening_balance(start_date)
    closing_balance = account.closing_balance(end_date)
    credits = transactions.credits.sum_amounts || 0
    debits = transactions.debits.sum_amounts || 0
    summary[:company_funds_summary] = {
        opening_balance: opening_balance,
        closing_balance: closing_balance,
        credits: credits,
        debits: debits,
        credit_summary: transactions_summary[:credits],
        debit_summary: transactions_summary[:debits]
    }
  end

  def set_company_expenses_summary(summary, user, start_date, end_date, application, options={})
    return unless options[:user_ids].present?
    card_ids = options[:card_ids]
    if card_ids.present?
      card_transactions = CardTransaction.with_card(card_ids).with_date_range(start_date, end_date).debits

      atm_withdrawals = card_transactions.atm_withdrawals
      atm_count = atm_withdrawals.count
      atm_amount = atm_withdrawals.sum_transaction_amount

      card_transactions = card_transactions.expensed_transactions
      card_exp_count = card_transactions.count
      card_exp_amount = card_transactions.sum_billing_amount

      balance_summary = {in_cards: 0, in_finly_money: 0, in_cash_on_hand: 0}
      user.company.users.include_all_accounts_with_balance.each do |user|
        user.cards.each do |card|
          next unless card.card_program_id == CardProgram.id_for(:expense)
          balance_summary[:in_cards] += card.card_balance_value rescue 0
        end
        balance_summary[:in_finly_money] += user.wallet.balance_value
        balance_summary[:in_cash_on_hand] += user.cash_in_hand.value rescue 0
      end

      summary[:accounts_summary] = {
          atm: {count: atm_count, amount: atm_amount},
          card_expenses: {count: card_exp_count, amount: card_exp_amount},
          total_amount_with_employees: balance_summary
      }
    end

    report_presenter = Reports::Index.(user, view: 'admin')
    if report_presenter.success?
      reports = report_presenter.reports.with_status_id(ReportStatus.ids_for([:processing, :approved, :settled, :settlement_confirmed, :closed]))
      expenses = Expense.reported.with_report_id(reports.pluck(:id)).with_date_range(start_date, end_date)
      manual_expenses = expenses.only_manual_expenses
      manual_expenses_count = manual_expenses.count
      manual_expenses_amount = manual_expenses.sum_amount

      card_expenses = expenses.only_card_expenses
      card_expenses_count = card_expenses.count
      card_expenses_amount = card_expenses.sum_amount

      time_expenses = expenses.only_time_expenses
      time_expenses_count = time_expenses.count
      time_expenses_amount = time_expenses.sum_amount

      distance_expenses = expenses.only_distance_expenses
      distance_expenses_count = distance_expenses.count
      distance_expenses_amount = distance_expenses.sum_amount

      per_diem_expenses = expenses.only_per_diem_expenses
      per_diem_expenses_count = per_diem_expenses.count
      per_diem_expenses_amount = per_diem_expenses.sum_amount

      total_count = (manual_expenses_count + card_expenses_count + time_expenses_count + distance_expenses_count + per_diem_expenses_count)
      total_amount = (manual_expenses_amount + card_expenses_amount + time_expenses_amount + distance_expenses_amount + per_diem_expenses_amount)

      summary[:expenses_summary] = {
          total: {count: total_count, amount: total_amount},
          manual_expenses: {count: manual_expenses_count, amount: manual_expenses_amount},
          card_expenses: {count: card_expenses_count, amount: card_expenses_amount},
          distance_expenses: {count: distance_expenses_count, amount: distance_expenses_amount},
          time_expenses: {count: time_expenses_count, amount: time_expenses_amount},
          per_diem_expenses: {count: per_diem_expenses_count, amount: per_diem_expenses_amount}
      }
    end
  end

end