class TravelRequests::Review::Submit < TravelRequests::Review::Base

  def authorized_user_types
    [:employee]
  end


  def validate
    unless travel_request.present?
      add_message :error, 'Travel Request not found'
      return
    end

    unless travel_request.can_submit?
      add_message :error, 'Travel Request cannot be submitted at this time'
      return
    end

    unless travel_request.user_id == user.id
      add_message :error, 'Only owner can submit a Travel Request'
      return
    end

    unless travel_request.destinations.present?
      add_message :error, 'Please add a destination to submit travel request'
      return
    end
  end

  def pre_process

  end

  def process
    presenter = User::Team::Review::NextReviewer.(travel_request)
    manager = presenter.user
    manager_role_id = presenter.role_id
    delegated_action_user_id = actual_current_user.present? ? actual_current_user.id : nil
    #######################################
    if manager.nil?
      # i.e. if there is no manager, the payment request directly goes to approved state
      # create a submit trail for the payment request
      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: UserRole.id_for(:employee),
                                                  action_id: TravelRequestTrailAction.id_for(:submit),
                                                  modified_user_id: manager&.id,
                                                  modified_user_role_id: manager_role_id
      approve_op = TravelRequests::Review::Approve.(user, id: travel_request.id, auto_approve: true)
      unless approve_op.success?
        add_message :error, approve_op.messages[:error]
        return false
      end
      return true
    end

    # if there is a manager after all
    submitted_at = DateTime.now
    if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:processing),
                                        controlling_user_id: manager&.id,
                                        controlling_user_role_id: manager_role_id,
                                        submitted_at: submitted_at

      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: UserRole.id_for(:employee),
                                                  action_id: TravelRequestTrailAction.id_for(:submit),
                                                  modified_user_id: manager&.id,
                                                  modified_user_role_id: manager_role_id,
                                                  delegated_action_user_id: delegated_action_user_id
      return true
    end
    add_message :error, travel_request.errors.full_messages
  end

  def post_process
    delegated_action_user_id = actual_current_user.present? ? actual_current_user.id : nil
    tr_comment_action = actual_current_user.present? ? :submitted_by_delegate : :submit
    # add comment
    travel_request.comments.create(user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(tr_comment_action), delegated_action_user_id: delegated_action_user_id)
    travel_request.money_requests.status_pending.update_all(
        controlling_user_id: travel_request.controlling_user_id,
        controlling_user_role_id: travel_request.controlling_user_role_id
    )
    # Event::EBankPaymentRequest::Submit.(user, travel_request: travel_request)
    add_message :success, "Travel request successfully submitted!"
  end
end