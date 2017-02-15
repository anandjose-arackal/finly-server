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
      messages[:error] << 'Cannot submit this money_request'
      return false
    end
    # checking if policy is added if enforce policy is enabled
    if user.enforce_policy_enabled?
      if money_request.policy.nil?
        add_message :error, "You have to select a policy for the money request before submission"
        return false
      end
    end
    # checking if the money_request has expenses
    unless money_request.total_amount> 0
      messages[:error] << 'Cannot submit an empty money request'
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
    presenter = User::Team::Review::NextReviewer.(money_request)
    manager = presenter.user
    manager_role_id = presenter.role_id
    # If no manager assigned, auto approve the money_request
    if manager.blank? and not money_request.payment_mode_card?
      # call the approve class with the right parameters
      approve_op = MoneyRequest::Approve.(user, {money_request_id: money_request.id, auto_approve: true})
      unless approve_op.success?
        self.messages[:error] = messages[:error].merge approve_op.messages[:error]
        # self.messages[:error] << "Error auto-approving money_request. Please try again."
        return
      end
      money_request.reload
      return
    end
    submitted_at = DateTime.now
    manager_id = manager.id rescue nil
    if money_request.update_attributes status_id: MoneyRequestStatus.id_for(:processing),
                                       controlling_user_id: manager_id,
                                       controlling_for_user_id: nil,
                                       controlling_user_role_id: manager_role_id,
                                       controlling_for_user_role_id: nil,
                                       submitted_at: submitted_at
      money_request.tracks.create action_user: user,
                                  action_user_role_id: UserRole.id_for(:employee),
                                  modified_user_id: money_request.controlling_user_id,
                                  modified_user_role_id: manager_role_id,
                                  money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:submit),
                                  status_id: MoneyRequestStatus.id_for(:processing)
      return true
    end
    messages[:error] = money_request.errors.full_messages
  end

  def post_process
    # adding comment regarding the change in status of this money request
    money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:submit)

    add_message :success, 'Money Request Submitted'
    
    Event::EMoneyRequest::Submit.(user, money_request: money_request)
  end

end
