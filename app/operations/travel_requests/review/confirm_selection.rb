class TravelRequests::Review::ConfirmSelection < TravelRequests::Review::Base

  def init
    travel_request_presenter = TravelRequests::Show.(user, params)
    unless travel_request_presenter.success?
      add_message :error, travel_request_presenter.messages[:error]
      return
    end
    self.travel_request = travel_request_presenter.travel_request
  end

  def validate
    # unless self.travel_request.controlling_user_id == user.id
    #   add_message :error, 'You cannot perform this action at the moment'
    #   return
    # end
    unless manager_view? or personal_view?
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
    unless self.travel_request.selection_processing? or self.travel_request.selection_requested? or self.travel_request.selection_rejected?
      add_message :error,  'You cannot perform this action at the moment'
      return
    end
  end

  def process
    # reviewer, reviewer_role_id = travel_booking_reviewer
    # controlling_user_role_id = travel_request.controlling_user_role_id
    # if reviewer.present?
    #   # Set reviewer as controlling user
    #   if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:selection_processing),
    #                                       controlling_user_id: reviewer&.id,
    #                                       controlling_user_role_id: reviewer_role_id
    #
    #     travel_request.travel_request_trails.create action_user: user,
    #                                                 action_user_role_id: controlling_user_role_id,
    #                                                 action_id: trail_action_id,
    #                                                 modified_user_id: reviewer&.id,
    #                                                 modified_user_role_id: reviewer_role_id
    #     return true
    #   end
    #   add_message :error, travel_request.errors.full_messages
    #   return
    # end
    #
    # travel_manager_user  = travel_manager
    # travel_manager_role_id = UserRole.id_for(:travel_manager)
    # # Approved -> Move travel booking back to travel desk
    # if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:selection_confirmed),
    #                                     controlling_user_id: travel_manager_user&.id,
    #                                     controlling_user_role_id: travel_manager_role_id
    #
    #   travel_request.travel_request_trails.create action_user: user,
    #                                               action_user_role_id: controlling_user_role_id,
    #                                               action_id: trail_action_id,
    #                                               modified_user_id: travel_manager_user&.id,
    #                                               modified_user_role_id: travel_manager_role_id
    #   return true
    # end
    # add_message :error, travel_request.errors.full_messages


    reviewer, reviewer_role_id = travel_booking_reviewer
    controlling_user_role_id = travel_request.controlling_user_role_id
    if reviewer.present?
      # Set reviewer as controlling user
      if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:selection_processing),
                                          controlling_user_id: reviewer&.id,
                                          controlling_user_role_id: reviewer_role_id

        travel_request.travel_request_trails.create action_user: user,
                                                    action_user_role_id: controlling_user_role_id,
                                                    action_id: trail_action_id,
                                                    modified_user_id: reviewer&.id,
                                                    modified_user_role_id: reviewer_role_id
        return true
      end
      add_message :error, travel_request.errors.full_messages
      return
    end

    travel_manager_user  = travel_manager
    travel_manager_role_id = UserRole.id_for(:travel_manager)
    # Approved -> Move travel booking back to travel desk
    if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:selection_confirmed),
                                        controlling_user_id: travel_manager_user&.id,
                                        controlling_user_role_id: travel_manager_role_id

      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: controlling_user_role_id,
                                                  action_id: trail_action_id,
                                                  modified_user_id: travel_manager_user&.id,
                                                  modified_user_role_id: travel_manager_role_id
      return true
    end
    add_message :error, travel_request.errors.full_messages
  end

  def post_process
    travel_request.comments.create user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(:selection_confirmed)
    travel_request.money_requests.status_pending.update_all(
        controlling_user_id: travel_request.controlling_user_id,
        controlling_user_role_id: travel_request.controlling_user_role_id
    )
    Event::ETravelRequest::ConfirmSelection.(user, travel_request: travel_request)
    add_message :success, 'Selection has been successfully confirmed'
  end

  protected

  def trail_action_id
    TravelRequestTrailAction.id_for(:selection_confirmed)
  end

  def travel_booking_reviewer
    controlling_user = self.travel_request.controlling_user
    purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
    # todo travel_booking_approves_to to be updated to travel_booking_verifier for confirm selection
    reviewer = controlling_user.team_mapping.with_purpose(purpose_id).policy(self.travel_request.policy_id).default.first&.travel_booking_approves_to
    return reviewer, UserRole.id_for(:manager) if reviewer.present?
    [nil, nil]
  end

  def travel_manager
    owner = self.travel_request.user
    purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
    owner.team_mapping.with_purpose(purpose_id).policy(self.travel_request.policy_id).default.first&.travel_manager
  end

end