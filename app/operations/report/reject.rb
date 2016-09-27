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
    if params[:reject_to_user_id].present?
      rejectable_users = User::Team::Review::RejectToUsersList.(self.report, self.user)
      self.reject_to_user = rejectable_users.with_id(params[:reject_to_user_id]).first if rejectable_users.present?
      return if self.reject_to_user.blank?
      if report.user.id == self.reject_to_user.id
        self.status = ReportStatus.rejected_id
      else
        self.status = ReportStatus.processing_id
      end
    else
      self.reject_to_user = self.report.user
      self.status = ReportStatus.rejected_id
    end
  end

  def authorize
    super
    unless report.controlling_user.id == user.id
      messages[:error] << 'You cannot reject the report at the moment'
      raise_unauthorized_exception
    end
  end

  def validate
    unless report.processing?
      messages[:error] << 'Cannot reject this report after the report is approved'
      return
    end
    unless reject_to_user.present?
      messages[:error] << 'Reject to user not found'
    end
  end

  def process
    user_role = User::Team::Review::UserRole.(user, self.report)
    if report.update_attributes report_status_id: status, controlling_user_id: reject_to_user.id, controlling_for_user_id: nil, memo: params[:memo]
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reject_id, report_status_id: status, memo: params[:memo],
                                  user_report_role_id: user_role
      track.save
      # Reset expenses status to unsubmitted if report is rejected
      if status == ReportStatus.rejected_id
        report.expenses.each do |expense|
          expense.update_attribute :expense_status_id, ExpenseStatus.unsubmitted_id
        end
      end
    end
  end

  def post_process
    if success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_reject), rejected_to_id: reject_to_user.id, content: params[:memo]
      comment.save
    end

    Event::EReport::Reject.(user, report: report)
    messages[:success] << "Report rejected"
  end

end