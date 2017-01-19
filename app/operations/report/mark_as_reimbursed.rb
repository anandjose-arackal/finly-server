# action to mark a report as reimbursed. This also marks the report as closed if the reimbursement amount was completely cancelled against the cash in hand
# params:
# payment_id: the payment with which this report was reimbursed
# report_id: id of the report(s) that is being reimbursed
# role_id: role id of the person accessing this action

class Report::MarkAsReimbursed < Report::Base
  attr_accessor :payment, :status, :cash_in_hand_deduction, :tracking_status

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def init
    self.report = params[:report]
    self.payment = params[:payment]
    self.cash_in_hand_deduction = params[:cash_in_hand_deduction]
    self.status = params[:status] || Report.reimbursed_id
    self.tracking_status = (params[:status]) ? ReportTrackingAction.id_for(:closed) : ReportTrackingAction.id_for(:reimbursed)
  end

  def validate
    unless report.reimbursement_pending?
      messages[:error] << 'Report cannot be reimbursed at this stage'
    end
    unless payment.present? or cash_in_hand_deduction.present?
      messages[:error] << 'Payment not found'
    end
  end

  def process
    if report.update_attributes controlling_user: nil,
                                controlling_for_user: nil,
                                controlling_user_role_id: nil,
                                controlling_for_user_role_id: nil,
                                report_status_id: status,
                                reimbursement: payment,
                                cash_in_hand_deduction: cash_in_hand_deduction
      # todo test this logic
      role_id = (self.user.finance_manager? and params.present? and finance_view?) ? UserRole.id_for(:finance_manager) : UserRole.id_for(:admin)
      report.tracks.create action_user: user,
                           action_user_role_id: role_id,
                           report_tracking_action_id: tracking_status,
                           report_status_id: status,
                           payment: self.payment,
                           cash_in_hand_deduction: cash_in_hand_deduction
    end
  end

  def post_process
    if success?
      report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_reimbursed), payment: self.payment
    end
  end
end