# action to reject a report.
# params:
# report_id: id of the report that is being rejected
# reject_to_user_id: id of the user that the report is to be rejected to

class Report::Reject < Report::Base

  attr_accessor :reject_to_user, :status

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def init
    super()
    if params[:reject_to_user_id]
      self.reject_to_user = user.company.users.find_by(id: params[:reject_to_user_id])
      if user.id == params[:reject_to_user_id]
        self.status = ReportStatus.rejected_id
      else
        self.status = ReportStatus.processing_id
      end
    else
      self.status = ReportStatus.rejected_id
    end
  end

  def authorize
    if reject_to_user
      rejectable_users = report.associated_users(user)
      unless rejectable_users.include?(reject_to_user)
        # i.e. reject it to the owner of the report if there is no reject_to_user present
        self.reject_to_user = report.user
      end
    end

    unless report.controlling_user.id == user.id
      raise_unauthorized_exception
      return false
    end
  end

  def validate
    unless report.processing?
      errors << 'Cannot reject this report after the report is approved'
      return false
    end
  end

  def process
    user_role = user_role_for_report
    if report.update_attributes report_status_id: status, controlling_user_id: reject_to_user.id, controlling_for_user_id: nil, memo: memo
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reject_id, report_status_id: status, memo: memo,
                                  user_report_role_id: user_role
      track.save
      # Reset expenses status to unsubmitted if report is rejected
      if status == ReportStatus.rejected_id
        report.expenses.each do |expense|
          expense.update_attribute :expense_status_id, ExpenseStatus.unsubmitted_id
        end
      end
      return true
    end
  end

  def post_process
    if is_success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reject_id, rejected_to_id: to_user.id, content: memo
      comment.save
    end
  end

end