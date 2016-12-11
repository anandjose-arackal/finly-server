class MoneyRequest::Comment::Create < MoneyRequest::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    content = (params[:comment] or params[:content])
    if content.blank?
      messages[:error] << 'Nothing to post'
    end
  end

  def process
    content = (params[:comment] or params[:content])
    comment = money_request.comments.build(comment_action_id: MoneyRequestCommentAction.id_for(:comment), user_id: user.id, content: content)
    unless comment.save
      add_message :error, comment.errors.full_messages
    end
  end

  def post_process
    Event::EMoneyRequest::EComment::Create.(self.user, money_request: self.money_request)
  end

end