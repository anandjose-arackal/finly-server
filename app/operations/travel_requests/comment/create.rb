# action to add comment to a report
# params:
# report_id: the report on which comment is to be made
# comment: content of the comment that is to be posted
#

class TravelRequests::Comment::Create < TravelRequests::Comment::Base
  attr_accessor :travel_request

  def authorized_user_types
    [:employee, :manager, :finance_manager, :auditor, :admin]
  end

  def pre_validate
    return unless user_present? and params_present?

    if params[:comment].blank? and params[:content].blank?
      add_message :error, 'Nothing to post'
    end
  end

  def init
    show_presenter = TravelRequests::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.travel_request = show_presenter.travel_request
  end

  def process
    content = (params[:comment] or params[:content])
    comment = travel_request.comments.build(action_id: TravelRequestCommentAction.id_for(:comment), user_id: user.id, content: content)
    unless comment.save
      add_message :error, comment.errors.full_messages
    end
  end

  def post_process
    # Event::EReport::EComment::Create.(user, report: self.report)
    add_message :success, 'Comment posted'
  end
end