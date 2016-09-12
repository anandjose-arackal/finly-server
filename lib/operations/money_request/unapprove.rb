class MoneyRequest::Unapprove < MoneyRequest::Base
  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'User or params not passed'
    end
  end

  def init
    id = (params[:money_request_id] or params[:id])
    self.money_request = MoneyRequest.find_by(id: id)
  end

  def authorize
    super
    if money_request.user_id == user.id
      messages[:error] << 'You cannot unapprove your own money_request'
      raise_unauthorized_exception
    end
  end

  def validate
    # checking if this user can unapprove this money_request at this stage
    associated_users = money_request.associated_users money_request.controlling_user
    unless associated_users.present? and associated_users.with_id(user.id).present?
      messages[:error] << 'User has not yet reviewed the money_request to unapprove it'
      return false
    end

    unless money_request.can_unapprove?
      messages[:error] << 'The money_request cannot be unapproved at this stage'
    end
  end

  def process
    self.prev_status = money_request.status
    if money_request.update_attributes controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil,
                                       money_request_status_id: MoneyRequestStatus.id_for(:processing)
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:unapprove),
                                         money_request_status_id: MoneyRequestStatus.id_for(:processing)
      return
    end
    messages[:error] << money_request.errors.full_messages
  end

  def post_process
    money_request.comments.create user: user, money_request_comment_action_id: MoneyRequestCommentAction.id_for(:unapprove)
    # Recalculate settlement when money_request is unapproved from an approved/closed state
    if prev_status.id == MoneyRequestStatus.id_for(:approved)
      Event::MoneyRequest::Unapprove.(self.user, money_request: self.money_request)
    end
  end
  
end