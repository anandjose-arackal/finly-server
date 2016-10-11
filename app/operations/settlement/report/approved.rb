# action that recomputes settlement once a report has been approved
# the user passed must be the report owner, NOT person approving it.
# params:
# report_id: id of the report being marked as approved
#

class Settlement::Report::Approved < Report::Base
  attr_accessor :report

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def init
    self.report = params[:report]
  end

  def validate
    if report.accounted?
      messages[:error] << 'Report has already been accounted for'
    end
  end

  def process
    balance_sheet = report.user.balance_sheet
    total_amount = report.total_amount
    currency = Currency.first # todo - temporary until currency is implemented
    latest_date = nil
    latest_date = report.latest_expense.date if report.latest_expense.present?
    cash_in_hand = balance_sheet.cash_in_hand latest_date
    pending_reimbursement = 0
    new_cash_in_hand_value = cash_in_hand.value - total_amount
    if new_cash_in_hand_value < 0
      pending_reimbursement = total_amount - cash_in_hand.value
      new_cash_in_hand_value = 0
    end
    report.user.balance_sheet.subtract_cash_in_hand (total_amount - pending_reimbursement), currency
    report.user.balance_sheet.add_pending_reimbursement pending_reimbursement, currency
    if report.reimbursement_amount.blank?
      report_amount = Amount.new(value: pending_reimbursement, currency: Currency.first)
      unless report_amount.save
        messages[:error] = report_amount.errors.full_messages
        return
      end
      report.reimbursement_amount = report_amount
    else
      report_amount = report.reimbursement_amount
      report_amount.value = pending_reimbursement
      report_amount.currency = currency
      unless report_amount.save
        messages[:error] = report_amount.errors.full_messages
        return
      end
    end
    report.accounted = true
    unless report.save
      messages[:error] = report.errors.full_messages
    end
  end

  def post_process
    # mailer
  end

  def success
    report
  end

end