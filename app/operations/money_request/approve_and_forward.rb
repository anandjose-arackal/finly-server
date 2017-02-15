class MoneyRequest::ApproveAndForward < MoneyRequest::Approve
  attr_accessor :forward_to_user

  def init
    super
    return if money_request.blank?
    forward_to_user_id = params[:forward_to_user_id]
    pending_approvers_presenter = User::Team::Review::PendingApprovers.(user, money_request: self.money_request)
    return if pending_approvers_presenter.blank? or pending_approvers_presenter.failure?
    if forward_to_user_id.present?
      self.forward_to_user = pending_approvers_presenter.approver_with_id(forward_to_user_id)
    else
      self.forward_to_user = pending_approvers_presenter.next_approver
    end
  end

  def validate
    super
    if forward_to_user.blank?
      add_message :error, 'Forward to user not found'
    end
  end

  def validate_payment_mode
    unless money_request.payment_mode_id == PaymentMode.id_for(:card)
      add_message :error, 'Error approving and forwarding money request. Use approve action'
    end
  end

  def process
    curr_user_role = User::Team::Review::UserRole.(user, self.money_request)
    to_user = forward_to_user[:approver]
    to_user_role_id = forward_to_user[:role_id]
    update_params = {}
    update_params[:controlling_user] = to_user
    update_params[:controlling_user_role_id] = to_user_role_id
    update_params[:controlling_for_user] = nil
    update_params[:controlling_for_user_id] = nil
    self.money_request.update_attributes update_params

    track_params = {}
    track_params[:action_user] = self.user
    track_params[:action_user_role_id] = curr_user_role
    track_params[:modified_user] = to_user
    track_params[:modified_user_role_id] = to_user_role_id
    track_params[:money_request_tracking_action_id] = MoneyRequestTrackingAction.id_for(:approve_and_forward)
    track_params[:status_id] = MoneyRequestStatus.id_for(:processing)
    self.money_request.tracks.create track_params

    # user: user, comment_action_id: MoneyRequestCommentAction.id_for(:approve)
    # todo rename rejected_to to something broader as this is approve and forward
    comment_params = {}
    comment_params[:user] = self.user
    comment_params[:comment_action_id] = MoneyRequestCommentAction.id_for(:approve_and_forward)
    comment_params[:rejected_to] = to_user
    self.money_request.comments.create comment_params
  end

  def post_process
    # todo sending notifications
    Event::EMoneyRequest::Approve.(self.user, money_request: self.money_request)

    if not has_errors? and money_request.payment_mode_id == PaymentMode.id_for(:card)
      add_message :success, 'Successfully approved and forwarded the money request'
    end
  end

end
