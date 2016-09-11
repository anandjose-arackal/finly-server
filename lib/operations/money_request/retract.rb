class MoneyRequest::Retract < MoneyRequest::Base

  def authorized_user_types
    :employee
  end

  def pre_validate
    if params[:id].blank?
      errors << 'Request not found'
    end
    if user.blank?
      errors << 'User not found'
    end
  end

  def init
    requests = user.money_requests.with_id(params[:id])
    self.money_request = requests.first if requests.present?
  end

  def authorize
    if self.money_request.blank?
      errors << 'You cannot retract this request'
      raise_unauthorized_exception
      return
    end
    unless self.money_request.user.id == user.id
      errors << 'Only owners can retract card load requests'
      raise_unauthorized_exception
    end
    unless self.money_request.processing?
      errors << 'Card Load Requests can only be retracted when in processing state'
      raise_unauthorized_exception
    end
  end

  def process
    if money_request.update_attributes status_id: MoneyRequestStatus.retracted_id, controlling_user_id: user.id,
                                           controlling_for_user_id: nil, note: self.params[:note]
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.retract_id,
                                      status_id: MoneyRequestStatus.retracted_id, user_request_role_id: UserRole.employee_id
      self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.retract_id
    else
      errors << money_request.errors.full_messages
    end
  end
end