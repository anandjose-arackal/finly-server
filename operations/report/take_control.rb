# action that takes control of the report when it is in processing state.
# params:
# report_id: id of the report that needs to be taken control of
# memo: optional memo from the user taking control of the report.

class Report::TakeControl < Report::Base

  def authorized_user_types
    [:admin, :policy_admin]
  end


  def authorize
    if user.policy_admin?
      if report.policy and not user.policy_admin?(report.policy) # that is the report has a policy and the user is not policy admin
        raise_unauthorized_exception
        return false
      end
    end
  end

  def validate
    unless report.can_take_control?
      errors << "Report cannot be taken control of at this stage."
      return false
    end
  end

  def process
    if report.update_attributes controlling_user: user, controlling_for_user: report.controlling_user, memo: params[:memo]
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.take_control_id,
                                  report_status_id: report.status_id, memo: params[:memo]
      track.save
      return true
    end
    return false
  end

  def post_process
    if is_success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_take_control_id, content: params[:memo]
      comment.save
    end
  end
end