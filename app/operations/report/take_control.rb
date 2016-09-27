# action that takes control of the report when it is in processing state.
# params:
# report_id: id of the report that needs to be taken control of
# memo: optional memo from the user taking control of the report.

class Report::TakeControl < Report::Base

  def authorized_user_types
    [:admin]
  end

  def authorize
    super
    if user.policy_admin?
      if report.policy and not user.policy_admin?(report.policy) # that is the report has a policy and the user is not policy admin
        raise_unauthorized_exception
      end
    end
  end

  def validate
    unless report.can_take_control?
      messages[:error] << 'Report cannot be taken control of at this stage'
    end
  end

  def process
    if report.update_attributes controlling_user: user, controlling_for_user: report.controlling_user, memo: params[:memo]
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.take_control_id,
                                  report_status_id: report.status_id, memo: params[:memo]
      track.save
      return
    end
    self.messages = report.errors.full_messages
  end

  def post_process
    if success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_take_control), content: params[:memo]
      comment.save
    end
    Event::EReport::TakeControl.(self.user, report: self.report)

    messages[:success] << "You've taken control of this report."
  end

end