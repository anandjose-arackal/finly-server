class Company::Statement::Summary < Company::Statement::Base

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
    items[:company_balance] = result.balance

    # calculating money with employees in various forms
    items[:employees] = {}
    items[:employees][:card_balance] = 0
    items[:employees][:wallet_balance] = 0
    items[:employees][:cash_in_hand_balance] = 0
    items[:employees][:total] = 0
    company.users.each do |user|
      items[:employees][:card_balance] += card_balance_on_date(user, end_date)
      items[:employees][:wallet_balance] += user_account_balance_on_date(user, end_date)
      items[:employees][:cash_in_hand_balance] += cash_in_hand_on_date(user, end_date)
    end
    items[:employees].each do |k, v|
      next if k == :total
      items[:employees][:total] += v
    end

    items[:total_advance_fund_requests] = 0
    items[:total_pending_reimbursements] = 0
    items[:total_cash_in_hand] = 0
    company.users.each do |user|
      # calculating advance fund totals
      (user.money_requests.approved + user.money_requests.credited_money_request).each do |request|
        items[:total_advance_fund_requests] += request.total_amount
      end

      # calculating amount pending in reimbursements
      user.reports.pending_reimbursement.each do |report|
        items[:total_pending_reimbursements] += report.reimbursement_amount.value rescue 0
      end

      # calculating cash given in advance
      items[:total_cash_in_hand] += user.cash_in_hand.value
    end
  end

  def success
    Company::Statement::Summary::SummaryPresenter.new(user, {items: items}, messages)
  end

  class Company::Statement::Summary::SummaryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :items

    def init
      self.items = params[:items]
    end
  end


  private

  # returns card balance on a particular day
  # if no date is passed it returns current card balance
  def card_balance_on_date(user, date = nil)
    balance_params = {}
    balance_params[:id] = user.id
    balance_params[:view] = nil

    result = User::PrepaidCard::Show.(user, balance_params)
    unless result.success?
      return 0
    end
    unless date
      return result.balance.to_f
    end
    card_expenses = user.card_transactions.debits.where('transaction_timestamp > ?', start_date).joins(:billing_amount).sum(:value)
    card_load_amount = user.receiving_payments.where('date > ?', date).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_card),
                                                                                               PaymentType.id_for(:credit_from_wallet_to_card)]).joins(:amount).sum(:value)
    balance = result.balance.to_f + card_load_amount - card_expenses
    precision_value  balance
  end

  # todo - revisit this calculation
  def cash_in_hand_on_date(selected_user, date = nil)
    balance = selected_user.cash_in_hand.value
    unless date
      return balance
    end
    debt_clearances = selected_user.payments.where('date > ?', date).where(payment_type_id: PaymentType.id_for(:debt_clearance)).joins(:amount).sum(:value)
    added_cash_in_hand = selected_user.payments.where('date > ?', date).where(payment_type_id: PaymentType.id_for(:advance)).joins(:amount).sum(:value)
    accounted_reports = selected_user.reports.where(report_status_id: [ReportStatus.approved_id, ReportStatus.closed_id]).where(accounted: true).where('accounted_at > ?', date)
    report_amount = 0
    accounted_reports.each do |report|
      report_amount += report.total_amount(:only_manual_expenses) - report.reimbursement_amount.value
    end
    balance = balance + debt_clearances - added_cash_in_hand + report_amount
    precision_value  balance
  end

  def user_account_balance_on_date(selected_user, date = nil)
    balance = selected_user.wallet.balance_amount
    unless date
      return precision_value balance
    end
    debits = selected_user.receiving_payments.where('date > ?', date).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_wallet),
                                                                                              PaymentType.id_for(:debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
    credits = selected_user.receiving_payments.where('date > ?', date).where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_wallet),
                                                                                               PaymentType.id_for(:credit_from_virtual_account_to_wallet)]).joins(:amount).sum(:value)
    balance = balance + debits - credits
    precision_value balance
  end

  def company_balance_on_date(date = nil)

  end

end
