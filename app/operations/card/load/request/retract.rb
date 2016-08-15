class Card::Load::Request::Retract < Card::Load::Request::Base

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
    requests = user.card_load_requests.with_id(params[:id])
    self.card_load_request = requests.first if requests.present?
  end

  def authorize
    if self.card_load_request.blank?
      errors << 'You cannot retract this request'
      raise_unauthorized_exception
      return
    end
    unless self.card_load_request.user.id == user.id
      errors << 'Only owners can retract card load requests'
      raise_unauthorized_exception
    end
    unless self.card_load_request.processing?
      errors << 'Card Load Requests can only be retracted when in processing state'
      raise_unauthorized_exception
    end
  end

  def process
    if card_load_request.update_attributes status_id: CardLoadRequestStatus.retracted_id, controlling_user_id: user.id,
                                 controlling_for_user_id: nil, note: self.params[:note]
      card_load_request.tracks.create action_user: user, card_load_tracking_action_id: CardLoadTrackingAction.retract_id,
                                             status_id: CardLoadRequestStatus.retracted_id, user_request_role_id: UserRole.employee_id
    else
      errors << card_load_request.errors.full_messages
    end
  end
end