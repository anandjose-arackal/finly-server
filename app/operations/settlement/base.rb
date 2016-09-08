class Settlement::Base < BaseOperation

  attr_accessor :to_user

  class Settlement::Base::BasePresenter < BaseOperation::BasePresenter


  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
      return false
    end
    # todo - temporary, will be changed once currencies is implemented. Error will be thrown if currency is not provided
    if params[:currency_id].blank?
      params[:currency_id] = 1
    end
  end


  def validate_date(date)
    if date.blank?
      errors << 'Date cannot be blank'
      return false
    end
    unless date.is_a?(Date)
      date = Date.parse(date)
    end

    if date.present? and date > Date.today
      errors << 'Date cannot be later than the current date'
      return false
    end
    return true
  end

  def cash_in_hand(user, date=nil)
    cash = user.balance_sheet.cash_in_hand
    return cash if date.blank? or date == Date.today
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

  # def retrieve
  #   if is_success?
  #     return true
  #   else
  #     return false
  #   end
  # end

  def success
    true
  end


end