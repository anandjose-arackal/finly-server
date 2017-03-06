# todo - whole thing needs to be rewritten

class EmployeeStatement::Summary < EmployeeStatement::Base
  include MathUtil

  attr_accessor :items

  def init
    super()
    self.items = {}
  end

  def authorize
    unless selected_user
      raise_unauthorized_exception
      return
    end
  end

  def validate

  end

  def process
    # table 1

    # Virtual account details
    items[:user_account_status_details] = {}
    items[:user_account_status_details][:account_load] = precision_value selected_user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_wallet),
                                                                                                                                                                                         PaymentType.id_for(:credit_from_wallet_to_wallet),
                                                                                                                                                                                         PaymentType.id_for(:cerdit_from_card_to_wallet)]).joins(:amount).sum(:value)
    # debugger
    items[:user_account_status_details][:account_withdrawal] = precision_value selected_user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_wallet),
                                                                                                                                                                                               PaymentType.id_for(:debit_from_wallet_to_virtual_account),
                                                                                                                                                                                               PaymentType.id_for(:debit_from_wallet_to_card)]).joins(:amount).sum(:value)
    items[:user_account_status_details][:account_transfer_to_other_accounts] = precision_value selected_user.initiating_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_wallet)]).joins(:amount).sum(:value)
    items[:user_account_status_details][:account_transfer_to_other_cards] = precision_value selected_user.initiating_payments.where('date >= ? AND date <= ?', start_date, end_date).non_personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card),
                                                                                                                                                                                                                          PaymentType.id_for(:credit_from_card_to_card)]).joins(:amount).sum(:value)

    # transferred to card
    items[:transferred_to_card] = {}
    items[:transferred_to_card][:from_own_account] = precision_value selected_user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card), PaymentType.id_for(:debit_from_wallet_to_card)]).joins(:amount).sum(:value)
    items[:transferred_to_card][:from_other_accounts] = precision_value selected_user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).non_personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card), PaymentType.id_for(:debit_from_wallet_to_card)]).joins(:amount).sum(:value)
    items[:transferred_to_card][:from_company_account] = precision_value selected_user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: PaymentType.id_for(:credit_from_virtual_account_to_card)).joins(:amount).sum(:value)

    # amount spent from card
    load_card_transactions

    # closing balances

    items[:account_closing_balance] = selected_user.user_balance_histories.find_by(date: end_date).finly_money_balance.value rescue 0
    items[:card_closing_balance] = selected_user.user_balance_histories.find_by(date: end_date).card_balance.value rescue 0
    items[:closing_cash_in_hand] = selected_user.user_balance_histories.find_by(date: end_date).cash_on_hand_balance.value rescue 0


    items[:user_account_opening_balance] = selected_user.user_balance_histories.find_by(date: start_date).finly_money_balance.value rescue 0


    # table 2

    items[:opening_card_balance] = selected_user.user_balance_histories.find_by(date: start_date).card_balance.value rescue 0
    items[:opening_cash_in_hand] = selected_user.user_balance_histories.find_by(date: start_date).cash_on_hand_balance.value rescue 0

    items[:amount_transacted] = {}
    items[:amount_transacted][:card_load] = precision_value selected_user.receiving_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:credit_from_virtual_account_to_card),
                                                                                                                                                                            PaymentType.id_for(:credit_from_wallet_to_card),
                                                                                                                                                                            PaymentType.id_for(:credit_from_card_to_card)]).joins(:amount).sum(:value)
    items[:amount_transacted][:card_load] += precision_value selected_user.initiating_payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_card),
                                                                                                                                                                            PaymentType.id_for(:debit_from_card_to_card)]).joins(:amount).sum(:value)
    items[:amount_transacted][:paid_to_employee] = precision_value selected_user.payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:add_cash_on_hand),
                                                                                                                                                                         PaymentType .id_for(:reimbursement)]).joins(:amount).sum(:value)
    items[:amount_transacted][:paid_by_employee] = precision_value selected_user.payments.where('date >= ? AND date <= ?', start_date, end_date).where(payment_type_id: [PaymentType.id_for(:deduct_cash_on_hand)]).joins(:amount).sum(:value) # todo - check if this should include settlement

    items[:total_verified_expenses] = {}
    items[:total_verified_expenses][:verified_card_expenses] = verified_card_expenses(selected_user)
    items[:total_verified_expenses][:verified_cash_expenses] = verified_cash_expenses(selected_user)

    items[:closing_card_balance] = selected_user.user_balance_histories.find_by(date: end_date).card_balance.value rescue 0
    items[:closing_cash_in_hand] = selected_user.user_balance_histories.find_by(date: end_date).cash_on_hand_balance.value rescue 0

    # table 3
    items[:declined_expenses] = {}
    items[:declined_expenses][:declined_card_expenses] = precision_value selected_user.expenses.where('date >= ? AND date <= ?', start_date, end_date).only_card_expenses.where(expense_status_id: ExpenseStatus.rejected_id).joins(:amount).sum(:value)
    items[:declined_expenses][:declined_cash_expenses] = precision_value selected_user.expenses.where('date >= ? AND date <= ?', start_date, end_date).only_manual_expenses.where(expense_status_id: ExpenseStatus.rejected_id).joins(:amount).sum(:value)

    items[:unreported_card_expenses] = precision_value selected_user.expenses.where('date >= ? AND date <= ?', start_date, end_date).only_card_expenses.where(expense_status_id: ExpenseStatus.unreported_id).joins(:amount).sum(:value)

    # items[:total_unverified_card_reversal] todo - need clarification from itzcash
    items[:processing_expenses] = {}
    items[:processing_expenses][:pending_card_expenses] = pending_card_expenses(selected_user)
    items[:processing_expenses][:pending_cash_expenses] = pending_cash_expenses(selected_user)
  end

  def success
    EmployeeStatement::Base::StatementPresenter.new(user, {items: items}, messages)
  end

  private

  def load_card_transactions
    items[:spent_from_card] = {}
    items[:spent_from_card][:atm] = precision_value selected_user.card_transactions.where('transaction_timestamp >= ? AND transaction_timestamp <= ?', start_date, end_date).where(transaction_mode: "ATM").joins(:billing_amount).sum(:value)
    items[:spent_from_card][:pos] = precision_value selected_user.card_transactions.where('transaction_timestamp >= ? AND transaction_timestamp <= ?', start_date, end_date).where(transaction_mode: "POS").joins(:billing_amount).sum(:value)
    items[:spent_from_card][:online] = precision_value selected_user.card_transactions.where('transaction_timestamp >= ? AND transaction_timestamp <= ?', start_date, end_date).where(transaction_mode: "Ecom").joins(:billing_amount).sum(:value) # todo - find out if this is different from online
  end


  def verified_card_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    approved_reports = selected_user.reports.where(report_status_id: [ReportStatus.approved, ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.closed_id])
    approved_reports.each do |report|
      card_ex = report.expenses.only_card_expenses.where('date >= ? AND date <= ?', start_date, end_date).joins(:amount).sum(:value) rescue 0
      total += card_ex
    end
    precision_value total
  end

  def verified_cash_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    approved_reports = selected_user.reports.where(report_status_id: [ReportStatus.approved, ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.closed_id])
    approved_reports.each do |report|
      card_manual = report.expenses.only_manual_expenses.where('date >= ? AND date <= ? ', start_date, end_date).joins(:amount).sum(:value) rescue 0
      total += card_manual
    end
    precision_value total
  end

  def pending_card_expenses(user = nil)
    unless user
      return 0
    end
    total = 0
    processing_reports = user.reports.processing
    processing_reports.each do |report|
      card_ex = report.expenses.only_card_expenses.where('date >= ? AND date <= ? ', start_date, end_date).joins(:amount).sum(:value) rescue 0
      total += card_ex
    end
    precision_value total
  end

  def pending_cash_expenses(user = nil)
    total = 0
    unless user
      return total
    end
    processing_reports = user.reports.processing
    processing_reports.each do |report|
      manual_ex = report.expenses.only_manual_expenses.where('date >= ? AND date <= ? ', start_date, end_date).joins(:amount).sum(:value) rescue 0
      total += manual_ex
    end
    precision_value  total
  end

end
