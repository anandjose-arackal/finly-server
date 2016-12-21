class SettlementService < BaseService
  include MathUtil
  attr_accessor :user

  def initialize(user = nil)
    super()
    self.user= user
  end

  # Check if user has sufficient cash in hand for the report expenses.
  def require_reimbursement?(report)
    rds = ReportDetailService.new(report)
    report_total = rds.total_amount
    latest_expense = rds.latest_expense
    date = nil
    date = latest_expense.date if latest_expense.present?
    cash = cash_in_hand date
    cash.value - report_total < 0
  end

  def cash_in_hand(date = nil)
    cash = user.balance_sheet.cash_in_hand
    return cash if date.blank? or date == DateUtils.local_date
    payments = user.payments.made_after(date).with_amount
    payments_to_user = payments.transferred_to_user.sum(:value)
    debt_clearance = payments.debt_clearance.sum(:value)
    settlement = payments.settlement.sum(:value)
    reports = user.reports.processed.submitted_after(date)
    report_ids = reports.pluck(:id)
    expenses = user.expenses.with_amount.with_report(report_ids).sum(:value)
    pending_reimbursement = reports.with_amount.without_payment.sum(:value)
    value = cash.value + expenses + debt_clearance + settlement - payments_to_user - pending_reimbursement
    Amount.new(value: value, currency: cash.currency)
  end

  def pending_reimbursement
    user.balance_sheet.pending_reimbursement
  end

  def add_cash_advance(initiating_user, date, note, value, currency=nil)
    date = parse_date date
    return false unless validate_value value, currency and validate_initiating_user initiating_user and validate_date date
    payment = user.payments.build(initiating_user: initiating_user, receiving_user: user, payment_type_id: PaymentType.id_for(:advance), date: date, note: note,
                                  amount_attributes: {value: value, currency_id: currency})
    balance_sheet = user.balance_sheet
    if payment.save and balance_sheet.add_cash_in_hand(value, currency)
      return true
    end
    self.errors = errors + payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def add_reimbursement(initiating_user, report_ids, date, note, val, currency=nil)
    date = parse_date date
    if report_ids.blank?
      errors << 'No reports selected'
      return false
    end
    return false unless validate_value val, currency and validate_initiating_user initiating_user and validate_date date
    reports = nil
    reports = user.reports.with_id(report_ids).with_amount if report_ids.present?
    unless report_ids.present? and reports.present?
      errors << 'Report not found'
      return false
    end
    value = nil
    value = val.to_f if val.present?
    total_amount = precision_value(reports.sum(:value))
    unless value == total_amount
      errors << 'Reimbursed amount is not matching total pending reimbursement amount for the selected reports'
      return false
    end
    payment = user.payments.build(initiating_user: initiating_user, receiving_user: user, payment_type_id: PaymentType.id_for(:reimbursement), date: date, note: note,
                                  amount_attributes: {value: value, currency_id: currency})
    balance_sheet = user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement value, currency
      reports.each do |report|
        ReportService.new(user: initiating_user, report: report).mark_as_reimbursed payment
      end
      return true
    end
    self.errors = errors + payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def add_debt_to_company_clearance(initiating_user, date, note, value, currency=nil)
    date = parse_date date
    return false unless validate_value value, currency and validate_initiating_user initiating_user and validate_date date
    balance_sheet = user.balance_sheet
    value = value.to_f if value.present?
    cash_in_hand_on_date = cash_in_hand date
    unless value <= cash_in_hand_on_date.value
      errors << 'Debt clearance cannot be greater than the cash in hand amount on the date of debt clearance'
      return false
    end
    payment = user.payments.build(initiating_user: initiating_user, receiving_user: user, payment_type_id: PaymentType.id_for(:debt_clearance), date: date, note: note,
                                  amount_attributes: {value: value, currency_id: currency})
    if payment.save and balance_sheet.subtract_cash_in_hand(value, currency)
      return true
    end
    self.errors = errors + payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  # Settle pending reimbursement of the selected reports against cash in hand
  def settle(initiating_user, report_ids, date, note, val, currency=nil)
    date = parse_date date
    if report_ids.blank?
      errors << 'No reports selected'
      return false
    end
    return false unless validate_value val, currency and validate_initiating_user initiating_user and validate_date date
    value = val.to_f if val.present?
    cash_in_hand_on_date = cash_in_hand date
    unless value <= cash_in_hand_on_date.value
      errors << 'Settlement amount cannot be greater than the cash in hand amount'
      return false
    end

    reports = nil
    reports = user.reports.with_id(report_ids).with_amount if report_ids.present?
    unless report_ids.present? and reports.present?
      errors << 'Report not found'
      return false
    end
    total_amount = precision_value(reports.sum(:value))
    unless value == total_amount
      errors << 'Settlement amount is not matching total pending reimbursement amount for the selected reports'
      return false
    end
    payment = user.payments.build(initiating_user: initiating_user, receiving_user: user, payment_type_id: PaymentType.id_for(:settlement),
                                  date: date, note: note,
                                  amount_attributes: {value: value, currency_id: currency})
    balance_sheet = user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement value, currency and balance_sheet.subtract_cash_in_hand value, currency
      reports.each do |report|
        ReportService.new(user: initiating_user, report: report).mark_as_reimbursed payment
      end
      return true
    end
    self.errors = errors + payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def report_approved(report)
    return false unless validate_report report, false
    user = report.user
    rds = ReportDetailService.new(report)
    balance_sheet = user.balance_sheet
    total_amount = rds.total_amount
    currency = rds.currency
    latest_date = nil
    latest_date = rds.latest_expense.date if rds.latest_expense.present?
    cash_in_hand = balance_sheet.cash_in_hand latest_date
    pending_reimbursement = 0
    new_cash_in_hand_value = cash_in_hand.value - total_amount
    if new_cash_in_hand_value < 0
      pending_reimbursement = total_amount - cash_in_hand.value
    end
    user.balance_sheet.subtract_cash_in_hand total_amount, currency
    user.balance_sheet.add_pending_reimbursement pending_reimbursement, currency
    if report.reimbursement_amount.blank?
      ra = Amount.new(value: pending_reimbursement, currency: currency)
      ra.save
      report.reimbursement_amount = ra
    else
      ra = report.reimbursement_amount
      ra.value = pending_reimbursement
      ra.currency = currency
      ra.save
    end
    report.accounted = true
    report.save
  end

  def report_unapproved(report)
    return false unless validate_report report, true
    user = report.user
    rds = ReportDetailService.new(report)
    total_amount = rds.total_amount
    currency = rds.currency
    pending_reimbursement = 0
    pending_reimbursement = report.reimbursement_amount.value if report.reimbursement_amount.present?
    user.balance_sheet.add_cash_in_hand (total_amount - pending_reimbursement), currency
    user.balance_sheet.subtract_pending_reimbursement pending_reimbursement, currency
    report.reimbursement_amount.update(value: 0) if report.reimbursement_amount.present?
    report.update(accounted: false)
  end

  private
  def validate_value(value, currency)
    errors.clear
    if value.blank? or value.to_i <= 0
      errors<< 'Payment value cannot be less or equal to 0'
    end
    if currency.blank?
      errors << 'Payment currency cannot be blank'
    end
    errors.blank?
  end

  def validate_initiating_user(initiating_user, should_be_finance=true)
    errors.clear
    if initiating_user.blank?
      errors << 'Initiating user cannot be blank'
    end
    if should_be_finance and initiating_user.present? and not (initiating_user.finance_manager? or initiating_user.admin?)
      errors << 'Only finance managers can clear debt'
      if not initiating_user.admin? and initiating_user.id == self.user.id
        errors << 'Finance manager cannot clear his own debt'
      end
    end
    errors.blank?
  end

  def validate_date(date)
    errors.clear
    if date.blank?
      errors << 'Date cannot be blank'
    end
    if date.present? and date > DateUtils.local_date
      errors << 'Date cannot be later than the currency date'
    end
    errors.blank?
  end

  def validate_report(report, should_be_accounted)
    errors.clear
    if report.blank?
      errors << 'Report not found'
    end
    if should_be_accounted and not report.accounted?
      errors << 'Report not yet accounted'
    elsif not should_be_accounted and report.accounted?
      errors << 'Report already accounted'
    end
    errors.blank?
  end

  def parse_date(date)
    return nil if date.blank?
    Date.parse(date)
  end


end