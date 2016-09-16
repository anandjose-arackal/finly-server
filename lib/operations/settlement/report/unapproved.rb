# action that recomputes settlement once a report is unapproved
# user passed must be report owner and NOT report person unapproving it
# params:
# report_id: id of the report that is being unapproved


class Settlement::Report::Unapproved < Report::Base
  attr_accessor :report

  def authorized_user_types
    [:employee]
  end

  def self.call(user, params)
    self.new(user, params).run
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
    total_amount = report.total_amount
    currency = report.currency
    pending_reimbursement = 0
    pending_reimbursement = report.reimbursement_amount.value if report.reimbursement_amount.present?
    user.balance_sheet.add_cash_in_hand (total_amount - pending_reimbursement), currency
    user.balance_sheet.subtract_pending_reimbursement pending_reimbursement, currency
    report.reimbursement_amount.update(value: 0) if report.reimbursement_amount.present?
    unless report.update_attributes(accounted: false)
      messages[:error] << report.errors.full_messages
    end
  end

  def post_process
    # mailer
  end

  def success
    report
  end

end