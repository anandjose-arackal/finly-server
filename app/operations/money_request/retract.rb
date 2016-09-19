class MoneyRequest::Retract < MoneyRequest::Base

  def authorized_user_types
    :employee
  end

  def pre_validate
    super
    id = (params[:id] or params[:report_id])
    if id.blank?
      messages[:error] << 'Error loading request'
    end
  end

  def init
    id = (params[:id] or params[:report_id])
    self.money_request = user.money_requests.with_id(id).first rescue nil
  end

  def authorize
    if self.money_request.blank?
      messages[:error] << 'You cannot retract this request'
      raise_unauthorized_exception
      return
    end
    unless self.money_request.user.id == user.id
      messages[:error] << 'Only owners can retract card load requests'
      raise_unauthorized_exception
    end
  end

  def validate
    unless self.money_request.processing?
      messages[:error] << 'Card Load Requests can only be retracted when in processing state'
    end
  end

  def process
    if money_request.update_attributes status_id: MoneyRequestStatus.id_for(:retracted), controlling_user_id: user.id,
                                           controlling_for_user_id: nil, note: self.params[:note], submitted_at: nil
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:retract),
                                      status_id: MoneyRequestStatus.id_for(:retracted), user_request_role_id: UserRole.id_for(:employee)
      money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:retract)
    else
      messages[:error] << money_request.errors.full_messages
    end
  end
end