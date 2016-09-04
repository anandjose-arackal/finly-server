# action to add comment to a report
# params:
# report_id: the report on which comment is to be made
# comment: content of the comment that is to be posted
#

class Report::Comment::Create < Report::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    super()
  end

  def validate
    super()
    if params[:comment].blank?
      errors << "No content to post."
    end
  end

  def process
    comment = report.comments.build(report_comment_action_id: ReportCommentAction.report_comment_id, user_id: user.id, content: params[:comment])
    if comment.save
      return true
    end
    self.errors = comment.errors.full_messages
  end

  def post_process
    # mailer?
  end
end