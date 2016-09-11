class MoneyRequest::Submit < MoneyRequest::Base

  def authorized_user_types
    [:employee]
  end

  def init
    id = (params[:money_request_id] or params[:id])
    self.money_request = user.money_requests.find_by(id: id)
  end

  def validate
    # checking money_request status
    unless money_request.can_submit?
      errors << 'Cannot submit this money_request'
      return false
    end
    # checking if the money_request has expenses
    unless money_request.total_amount> 0
      errors << 'Cannot submit an empty money_request'
    end
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
      return false
    end
    
    # Only request owners can submit request
    unless money_request.user_id == user.id
      raise_unauthorized_exception
    end
  end
  
  def process
    manager = User::Team::Review::NextReviewer.(money_request)
    # If no manager assigned, auto approve the money_request
    if manager.blank?
      # call the approve class with the right parameters
      approve_op = MoneyRequest::Approve.new(user, {money_request_id: money_request.id, auto_approve: true})
      unless approve_op.run
        self.errors = self.errors.merge approve_op.errors
        # self.errors << "Error auto-approving money_request. Please try again."
        return
      end
      money_request.reload
      return
    end
    memo = params[:memo]
    submitted_at = DateTime.now
    if money_request.update_attributes money_request_status_id: MoneyRequestStatus.id_for(:processing),
                                       controlling_user_id: manager.id, controlling_for_user_id: nil, memo: memo,
                                       submitted_at: submitted_at
      money_request.tracks.create action_user: user,
                                         money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:submit),
                                         money_request_status_id: MoneyRequestStatus.id_for(:processing), memo: memo
      return true
    end
    errors << money_request.errors.full_messages
  end

end