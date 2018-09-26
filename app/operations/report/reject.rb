# action to reject a report.
# params:
# report_id: id of the report that is being rejected
# reject_to_user_id: id of the user that the report is to be rejected to

class Report::Reject < Report::Base
  attr_accessor :reject_to_user, :reject_to_user_role_id, :status

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def init
    super()
    # todo allow rejecting to users
    if params[:reject_to_user_id].present?
      rejectable_users = User::Team::Review::RejectToUsersList.(self.report, self.user)
      self.reject_to_user = rejectable_users.with_id(params[:reject_to_user_id]).first if rejectable_users.present?
      return if self.reject_to_user.blank?
      if report.user.id == self.reject_to_user.id
        self.status = ReportStatus.rejected_id
        self.reject_to_user_role_id = UserRole.id_for(:employee)
      else
        self.status = ReportStatus.processing_id
        self.reject_to_user_role_id =User::Team::Review::UserRole.(reject_to_user, self.report)
      end
    else
      self.reject_to_user = self.report.user
      self.status = ReportStatus.rejected_id
      self.reject_to_user_role_id = UserRole.id_for(:employee)
    end
    # self.reject_to_user = self.report.user
    # self.status = ReportStatus.rejected_id
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
    if params[:reject_note].blank?
      add_message :error, 'Please provide a reason for rejection'
      return
    end
  end

  def process
    user_role = User::Team::Review::UserRole.(user, self.report)
    if report.update_attributes report_status_id: status,
                                controlling_user_id: reject_to_user.id,
                                controlling_for_user_id: nil,
                                controlling_user_role_id: reject_to_user_role_id,
                                controlling_for_user_role_id: nil
      report.tracks.create action_user: user,
                                  action_user_role_id: user_role,
                                  modified_user_id: reject_to_user.id,
                                  modified_user_role_id: reject_to_user_role_id,
                                  report_tracking_action_id: ReportTrackingAction.id_for(:reject),
                                  report_status_id: status
      # Reset expenses status to unsubmitted if report is rejected
      if status == ReportStatus.rejected_id
        report.expenses.each do |expense|
          expense.update_attribute :expense_status_id, ExpenseStatus.id_for(:unsubmitted)
        end
      end
    end
  end

  def post_process
    if success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_reject),
                                      rejected_to_id: reject_to_user.id, content: params[:reject_note]
      comment.save
    end
    # destroying the submitted amount field
    report.submitted_amount.destroy

    # Invalidate all existing Email Authorizations
    email_auth_invalidate_presenter = EmailAuthorization::Invalidate.(user, authorizable: report)

    Event::EReport::Reject.(user, report: report)
    messages[:success] << "Report rejected"
  end

end