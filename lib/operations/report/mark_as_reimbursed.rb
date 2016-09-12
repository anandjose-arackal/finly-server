# action to mark a report as reimbursed.
# params:
# payment_id: the payment with which this report was reimbursed
# report_id: id of the report(s) that is being reimbursed
# role_id: role id of the person accessing this action

class Report::MarkAsReimbursed < Report::Base
  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def init
    super()
    self.payment = Payment.find_by(id: params[:payment_id])
  end

  def authorize

  end

  def validate
    unless report.reimbursement_pending?
      messages[:error] << "Report cannot be reimbursed at this stage."
      return false
    end
  end

  def process
    if report.update_attributes controlling_user: nil, controlling_for_user: nil, report_status_id: ReportStatus.reimbursed_id, memo: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reimbursed_id, report_status_id: ReportStatus.reimbursed_id
      track.save
    end
  end

  def post_process
    if success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reimbursed_id
      comment.save
    end
  end
end