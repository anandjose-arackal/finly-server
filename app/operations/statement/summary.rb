
class Statement::Summary < Statement::Base

  attr_accessor :items, :start_date, :end_date

  def init
    load_selected_user
    if params[:filter_date_from]
      self.start_date = params[:start_date]
    else
      self.start_date = Date.parse("01-01-1990") # arbitrarily chosen as the lower bound date
    end
    if params[:filter_date_to]
      self.end_date = params[:end_date]
    else
      self.end_date = Date.today
    end
    self.items = {}
  end

  def authorize
    unless selected_user
      raise_unauthorized_exception
      return
    end
  end

  def validate
    if end_date > DateUtils.local_date
      messages[:error] << "End Date cannot be in the future"
    end
  end

  def process
    # table 1
    items[:user_account_opening_balance] = user_account_balance(start_date)

    # Virtual account details
    items[:user_account_status_details] = {}
    items[:user_account_status_details][:account_load] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:receive_credit_from_virtual_account_to_wallet),
                                                                          PaymentType.id_for(:receive_credit_from_wallet_to_wallet)]).joins(:amount).sum(:value)
    items[:user_account_status_details][:account_withdrawal] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:receive_debit_from_wallet_to_wallet),
                                                                                PaymentType.id_for(:receive_debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
    items[:user_account_status_details][:account_transfer_to_other_accounts] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:initiate_credit_from_wallet_to_wallet)]).joins(:amount).sum(:value)
    items[:user_account_status_details][:account_transfer_to_other_cards] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).non_personal.where(payment_type_id: [PaymentType.id_for(:initiate_credit_from_wallet_to_card)]).joins(:amount).sum(:value)

    # transferred to card
    items[:transferred_to_card] = {}
    items[:transferred_to_card][:from_own_account] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).personal.where(payment_type_id: PaymentType.id_for(:receive_credit_from_wallet_to_card)).joins(:amount).sum(:value)
    items[:transferred_to_card][:from_other_accounts] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).non_personal.where(payment_type_id: PaymentType.id_for(:receive_credit_from_wallet_to_card)).joins(:amount).sum(:value)
    items[:transferred_to_card][:from_company_account] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: PaymentType.id_for(:receive_credit_from_virtual_account_to_card)).joins(:amount).sum(:value)

    # amount spent from card
    load_card_transactions

    # closing balances

    items[:account_closing_balance] = user_account_balance(end_date)
    items[:card_closing_balance] = card_balance(end_date)
    items[:closing_cash_in_hand] = cash_in_hand_on_date(end_date)

    # table 2

    items[:opening_card_balance] = card_balance(start_date)
    items[:opening_cash_in_hand] = cash_in_hand_on_date(start_date)

    items[:amount_transacted] = {}
    items[:amount_transacted][:card_load] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:receive_credit_from_virtual_account_to_card),
                                                                       PaymentType.id_for(:receive_credit_from_wallet_to_card)]).joins(:amount).sum(:value)
    items[:amount_transacted][:paid_to_employee] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:advance),
                                                                              PaymentType .id_for(:reimbursement)]).joins(:amount).sum(:value)
    items[:amount_transacted][:paid_by_employee] = selected_user.payments.where('date > ? AND date < ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:debt_clearance)]).joins(:amount).sum(:value) # todo - check if this should include settlement

    items[:total_verified_expenses] = {}
    items[:total_verified_expenses][:verified_card_expenses] = verified_card_expenses(selected_user)
    items[:total_verified_expenses][:verified_cash_expenses] = verified_cash_expenses(selected_user)

    items[:closing_card_balance] = card_balance(end_date)
    items[:closing_cash_in_hand] = cash_in_hand_on_date(end_date)

    # table 3
    items[:declined_expenses] = {}
    items[:declined_expenses][:declined_card_expenses] = selected_user.expenses.where('date > ? AND date < ?', start_date, end_date).only_card_expenses.where(expense_status_id: ExpenseStatus.rejected_id).joins(:amount).sum(:value)
    items[:declined_expenses][:declined_cash_expenses] = selected_user.expenses.where('date > ? AND date < ?', start_date, end_date).only_manual_expenses.where(expense_status_id: ExpenseStatus.rejected_id).joins(:amount).sum(:value)

    items[:unreported_card_expenses] = selected_user.expenses.where('date > ? AND date < ?', start_date, end_date).only_card_expenses.where(expense_status_id: ExpenseStatus.unreported_id).joins(:amount).sum(:value)

    # items[:total_unverified_card_reversal] todo - need clarification from itzcash
    items[:processing_card_expenses] = {}
    items[:processing_card_expenses][:pending_card_expenses] = pending_card_expenses(selected_user)
    items[:processing_card_expenses][:pending_cash_expenses] = pending_cash_expenses(selected_user)
  end

  def success
    Statement::Base::StatementPresenter.new(user, {items: items}, messages)
  end

  private

  def load_card_transactions
    items[:spent_from_card] = {}
    items[:spent_from_card][:atm] = selected_user.card_transactions.where('transaction_timestamp > ? AND transaction_timestamp < ?', start_date, end_date).where(transaction_mode: "ATM").joins(:billing_amount).sum(:value)
    items[:spent_from_card][:pos] = selected_user.card_transactions.where('transaction_timestamp > ? AND transaction_timestamp < ?', start_date, end_date).where(transaction_mode: "POS").joins(:billing_amount).sum(:value)
    items[:spent_from_card][:online] = selected_user.card_transactions.where('transaction_timestamp > ? AND transaction_timestamp < ?', start_date, end_date).where(transaction_mode: "Ecom").joins(:billing_amount).sum(:value) # todo - find out if this is different from online
  end

  def user_account_balance(date = nil)
    balance = user.wallet.balance_amount
    unless date
      return balance
    end
    debits = selected_user.payments.where('date > ?', date).where(payment_type_id: [PaymentType.id_for(:receive_debit_from_wallet_to_wallet),
                                                            PaymentType.id_for(:receive_debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
    credits = selected_user.payments.where('date > ?', date).where(payment_type_id: [PaymentType.id_for(:receive_credit_from_wallet_to_wallet),
                                                             PaymentType.id_for(:receive_credit_from_virtual_account_to_wallet)]).joins(:amount).sum(:value)
    balance = balance + debits - credits
    return balance
  end

  def verified_card_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    approved_reports = selected_user.reports.where(report_status_id: [ReportStatus.approved, ReportStatus.reimbursed_id, ReportStatus.reimbursement_confirmed_id, ReportStatus.closed_id])
    approved_reports.each do |report|
      card_ex = report.expenses.only_card_expenses.where('date > ?', date).joins(:amount).sum(:value) rescue 0
      total += card_ex
    end
    total
  end

  def verified_cash_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    approved_reports = selected_user.reports.where(report_status_id: [ReportStatus.approved, ReportStatus.reimbursed_id, ReportStatus.reimbursement_confirmed_id, ReportStatus.closed_id])
    approved_reports.each do |report|
      card_manual = report.expenses.only_manual_expenses.where('date > ?', date).joins(:amount).sum(:value) rescue 0
      total += card_manual
    end
    total
  end

  def pending_card_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    processing_reports = user.reports.processing
    processing_reports.each do |report|
      card_ex = report.expenses.only_card_expenses.joins(:amount).sum(:value) rescue 0
      total += card_ex
    end
    return total
  end

  def pending_cash_expenses(user = nil)
    unless user
      total = 0
      return total
    end
    processing_reports = user.reports.processing
    processing_reports.each do |report|
      manual_ex = report.expenses.only_manual_expenses.joins(:amount).sum(:value) rescue 0
      total += manual_ex
    end
    return total
  end

  # returns card balance on a particular day
  # if no date is passed it returns current card balance
  def card_balance(date = nil)
    result = User::PrepaidCard::Show.(selected_user, params)
    unless date
      return result.balance.to_f
    end
    card_expenses = user.card_transactions.debits.where('transaction_timestamp > ?', start_date).joins(:billing_amount).sum(:value)
    card_load_amount = user.payments.where('date > ?', date).where(payment_type_id: [PaymentType.id_for(:receive_credit_from_virtual_account_to_card),
                                                             PaymentType.id_for(:receive_credit_from_wallet_to_card)]).joins(:amount).sum(:value)
    balance = result.balance.to_f + card_load_amount - card_expenses
    return balance
  end

  # todo - revisit this calculation
  def cash_in_hand_on_date(date = nil)
    balance = user.cash_in_hand.value
    unless date
      return balance
    end
    debt_clearances = user.payments.where('date > ?', end_date).where(payment_type_id: PaymentType.id_for(:debt_clearance)).joins(:amount).sum(:value)
    added_cash_in_hand = user.payments.where('date > ?', end_date).where(payment_type_id: PaymentType.id_for(:advance)).joins(:amount).sum(:value)
    accounted_reports = user.reports.where(report_status_id: [ReportStatus.approved_id, ReportStatus.closed_id]).where(accounted: true)
    report_amount = 0
    accounted_reports.each do |report|
      report_amount += report.total_amount(:only_manual_expenses) - report.reimbursement_amount.value
    end
    balance = balance + debt_clearances - added_cash_in_hand + report_amount
    return balance
  end

end