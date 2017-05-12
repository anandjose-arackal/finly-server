# action that recomputes settlement once a report is unapproved
# user passed must be report owner and NOT report person unapproving it
# params:
# report_id: id of the report that is being unapproved


class Settlement::Report::Unapproved < Report::Base
  attr_accessor :report

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    self.report = params[:report]
  end

  def validate
    unless report.accounted?
      messages[:error] << 'Report has not been accounted for'
    end
  end

  def process
    currency = Currency.first.id
    reimbursable_expenses_total = 0
    reimbursable_expenses_total = report.reimbursable_expenses_total.value if report.reimbursable_expenses_total.present?
    report.user.balance_sheet.subtract_approved_reports_total reimbursable_expenses_total, currency
    report.reimbursable_expenses_total.update(value: 0) if report.reimbursable_expenses_total.present?
    report.non_reimbursable_expenses_total.update(value: 0) if report.non_reimbursable_expenses_total.present?
    report.card_expenses_total.update(value: 0) if report.card_expenses_total.present?
    unless report.update_attributes(accounted: false)
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