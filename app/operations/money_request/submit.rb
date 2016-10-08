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
    # checking if the money_request has expenses
    unless money_request.total_amount> 0
      messages[:error] << 'Cannot submit an empty advance request'
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
    if manager.blank?
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
    memo = (params[:note] or params[:memo] or money_request.memo)
    submitted_at = DateTime.now
    if money_request.update_attributes status_id: MoneyRequestStatus.id_for(:processing),
        controlling_user_id: manager.id,
        controlling_for_user_id: nil,
        controlling_user_role_id: manager_role_id, controlling_for_user_role_id: nil,
        memo: memo,
        submitted_at: submitted_at
      money_request.tracks.create action_user: user, modified_user_id: money_request.controlling_user_id,
        modified_user_role_id: manager_role_id,
        money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:submit),
        status_id: MoneyRequestStatus.id_for(:processing), memo: memo
      return true
    end
    messages[:error] = money_request.errors.full_messages
  end

  def post_process
    # adding comment regarding the change in status of this money request
    money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:submit)

    messages[:success] << 'Money Request Submitted'
  end

end
