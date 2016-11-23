
class Statement::Summary < Statement::Base

  attr_accessor :items, :start_date, :end_date

  def pre_validate

  end

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
  end

  def authorize
    unless selected_user
      raise_unauthorized_exception
      return
    end
  end

  def process

    # table 1
    # items[:user_account_balance] = # needs to be calculated from wallet transactions
    # items[:]

    # Virtual account details
    items[:account_load] = selected_user.payments.where(payment_type_id: [PaymentType.id_for(:receive_credit_from_virtual_account_to_wallet),
                                                                          PaymentType.id_for(:receive_credit_from_wallet_to_wallet)]).where().joins(:amount).sum(:value)
    items[:account_withdrawal] = selected_user.payments.where(payment_type_id: [PaymentType.id_for(:receive_debit_from_wallet_to_wallet),
                                                                                PaymentType.id_for(:receive_debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
    items[:account_transfer_to_other_accounts] = selected_user.payments.where(payment_type_id: [PaymentType.id_for(:initiate_credit_from_wallet_to_wallet)])
    items[:account_transfer_to_other_cards] = selected_user.payments.non_personal.where(payment_type_id: [PaymentType.id_for(:initiate_credit_from_wallet_to_card)])

    # transferred to card
    items[:from_own_account] = selected_user.payments.personal.where(payment_type_id: PaymentType.id_for(:receive_credit_from_wallet_to_card)).joins(:amount).sum(:value)
    items[:from_other_accounts] = selected_user.payments.non_personal.where(payment_type_id: PaymentType.id_for(:receive_credit_from_wallet_to_card)).joins(:amount).sum(:value)
    items[:from_company_account] = selected_user.payments.where(payment_type_id: PaymentType.id_for(:receive_credit_from_virtual_account_to_card)).joins(:amount).sum(:value)

    # amount spent from card
    load_card_transactions

    # closing balances
    items[:account_closing_balance]
    items[:card_closing_balance] = card_balance(date)
    items[:cash_in_hand]

    # table 2
    items[:opening_card_balance]
    items[:opening_cash_in_hand]
    items[:card_load] = selected_user.payments.where(payment_type_id: [PaymentType.id_for(:receive_credit_from_virtual_account_to_card),
                                                                       PaymentType.id_for(:receive_credit_from_wallet_to_card)]).joins(:amount).sum(:value)
    items[:card_withdrawal]
    items[:paid_to_employee] = selected_user.payments.where(payment_type_id: [PaymentType.id_for(:advance),
                                                                              PaymentType .id_for(:reimbursement)]).joins(:amount).sum(:value)
    items[:paid_by_employee] = selected_user.payments.where(payment_type_id: [PaymentType.id_for(:debt_clearance)]).joins(:amount).sum(:value) # todo - check if this should include settlement
    items[:verified_card_expenses] = verified_card_expenses(selected_user)
    items[:verified_cash_expenses]

    items[:closing_card_balance]
    items[:closing_cash_in_hand]

    # table 3
    items[:declined_card_expenses] = selected_user.expenses.only_card_expenses.where(expense_status_id: ExpenseStatus.rejected_id).joins(:amount).sum(:value)
    items[:declined_cash_expenses] = selected_user.expenses.only_manual_expenses.where(expense_status_id: ExpenseStatus.rejected_id).joins(:amount).sum(:value)
    items[:unreported_card_expenses] = selected_user.expenses.only_card_expenses.where(expense_status_id: ExpenseStatus.unreported_id).joins(:amount).sum(:value)

    items[:total_unverified_card_reversal]

    items[:pending_card_expenses] = pending_card_expenses(selected_user)
    items[:pending_cash_expenses] = pending_cash_expenses(selected_user)

  end

  private

  def load_card_transactions
    items[:atm] = card.transactions.where(transaction_mode: "ATM").joins(:billing_amount).sum(:value)
    items[:pos] = card.transactions.where(transaction_mode: "POS").joins(:billing_amount).sum(:value)
    items[:online] = card.transactions.where(transaction_mode: "Ecom").joins(:billing_amount).sum(:value) # todo - find out if this is different from online
  end

  def verified_card_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    approved_reports = selected_user.reports.where(report_status_id: [ReportStatus.approved, ReportStatus.reimbursed_id, ReportStatus.reimbursement_confirmed_id, ReportStatus.closed_id])
    approved_reports.each do |report|
      card_ex = report.expenses.only_card_expenses.joins(:amount).sum(:value) rescue 0
      total += card_ex
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
    total
  end

  def pending_cash_expenses(user = nil)
    unless user
      total = 0
    end
    processing_reports = user.reports.processing
    processing_reports.each do |report|
      manual_ex = report.expenses.only_manual_expenses.joins(:amount).sum(:value) rescue 0
      total += manual_ex
    end
    total
  end

  # returns card balance on a particular day
  # if no date is passed it returns current card balance
  def card_balance(date = nil)
    result = User::PrepaidCard::Show.(selected_user, params)
    unless date
      return result.balance
    end
    card_expenses = user.card_transactions.debits.where('transaction_timestamp > ?', start_date).joins(:billing_amount).sum(:value)
    card_load_amount = user.payments.where(payment_type_id: [PaymentType.id_for(:receive_credit_from_virtual_account_to_card),
                                                             PaymentType.id_for(:receive_credit_from_wallet_to_card)]).joins(:amount).sum(:value)
    balance = result.balance + card_load_amount - card_expenses
    return balance
  end

  def cash_in_hand_on_date(date = nil)
    balance = user.cash_in_hand
    unless date
      return balance
    end
  end

end