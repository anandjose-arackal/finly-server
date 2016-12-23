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
    self.report = params[:report]
    self.payment = params[:payment]
  end

  def validate
    unless report.reimbursement_pending?
      messages[:error] << 'Report cannot be reimbursed at this stage'
    end
    unless payment.present?
      messages[:error] << 'Payment not found'
    end
  end

  def process
    if report.update_attributes controlling_user: nil,
                                controlling_for_user: nil,
                                controlling_user_role_id: nil,
                                controlling_for_user_role_id: nil,
                                report_status_id: ReportStatus.reimbursed_id,
                                reimbursement: payment
      # todo test this logic
      role_id = (self.user.finance_manager? and params.present? and finance_view?) ? UserRole.id_for(:finance_manager) : UserRole.id_for(:admin)
      report.tracks.create action_user: user,
                           action_user_role_id: role_id,
                           report_tracking_action_id: ReportTrackingAction.reimbursed_id,
                           report_status_id: ReportStatus.reimbursed_id,
                           payment: self.payment
    end
  end

  def post_process
    if success?
      report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_reimbursed), payment: self.payment
    end
  end
end