# action to mark a report as reimbursed.
# params:
# payment_id: the payment with which this report was reimbursed
# report_id: id of the report that is being reimbursed

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
    # todo - confirm this check once
    unless report.controlling_user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    if report.update_attributes controlling_user: nil, controlling_for_user: nil, report_status_id: ReportStatus.reimbursement_confirmed_id, memo: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reimbursement_confirmed_id, report_status_id: ReportStatus.reimbursement_confirmed_id
      track.save
    end
  end

  def post_process
    if is_success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reimbursement_confirmed_id
      comment.save
    end
  end
end