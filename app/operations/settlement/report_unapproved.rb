# action that recomputes settlement once a report is unapproved
# user passed must be report owner and NOT report approver
# params:
# report_id: id of the report that is being unapproved


class Settlement::ReportUnapproved < Settlement::Base

  attr_accessor :report

  def authorized_user_types
    [:employee]
  end

  def self.call(user, params)
    self.new(user, params).run
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def init
    self.report = user.reports.find_by(id: params[:report_id])
  end

  def authorize
    unless report
      raise_unauthorized_exception
    end
  end

  def validate
    unless report.accounted?
      errors << "Report has not been accounted for. Chill out."
    end
  end

  def process
    total_amount = report.total_amount
    currency = report.currency
    pending_reimbursement = 0
    pending_reimbursement = report.reimbursement_amount.value if report.reimbursement_amount.present?
    user.balance_sheet.add_cash_in_hand (total_amount - pending_reimbursement), currency
    user.balance_sheet.subtract_pending_reimbursement pending_reimbursement, currency
    report.reimbursement_amount.update(value: 0) if report.reimbursement_amount.present?
    if report.update(accounted: false)
      return true
    end
    errors << report.errors.full_messages
    return false
  end

  def post_process
    # mailer
  end

  def retrieve
    if is_success?
      return report
    else
      return false
    end
  end
end