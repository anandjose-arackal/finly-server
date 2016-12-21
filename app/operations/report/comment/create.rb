# action to add comment to a report
# params:
# report_id: the report on which comment is to be made
# comment: content of the comment that is to be posted
#

class Report::Comment::Create < Report::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    if params[:comment].blank? and params[:content].blank?
      add_message :error, 'Nothing to post'
    end
  end

  def process
    content = (params[:comment] or params[:content])
    comment = report.comments.build(report_comment_action_id: ReportCommentAction.id_for(:report_comment), user_id: user.id, content: content)
    unless comment.save
      add_message :error, comment.errors.full_messages
    end
  end

  def post_process
    Event::EReport::EComment::Create.(user, report: self.report)
    add_message :success, 'Comment posted'
  end
end