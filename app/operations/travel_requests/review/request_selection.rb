class TravelRequests::Review::RequestSelection < TravelRequests::Review::Base
  attr_accessor :travel_request

  def authorized_user_types
    [:travel_manager]
  end

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

    unless self.travel_request.bookings.options.present?
      add_message :error, 'Please add atleast one option to request for selection'
      return
    end

    # todo status validation
    # validate if necessary booking requests with unselected options are available
  end

  def process
    # selector, selector_role_id = travel_booking_selector
    # selection_requested_at = DateTime.now
    # if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:selection_requested),
    #                                     controlling_user_id: selector&.id,
    #                                     controlling_user_role_id: selector_role_id,
    #                                     submitted_at: selection_requested_at
    #
    #   travel_request.travel_request_trails.create action_user: user,
    #                                               action_user_role_id: UserRole.id_for(:travel_manager),
    #                                               action_id: TravelRequestTrailAction.id_for(:selection_requested),
    #                                               modified_user_id: selector&.id,
    #                                               modified_user_role_id: selector_role_id
    #   return true
    # end
    # add_message :error, travel_request.errors.full_messages


    # NEW CODE
    #  Workflow Manager
    params[:document] = self.travel_request
    params[:aasm_event] = 'request_selection'
    params[:provider_name] = 'TravelRequestBookingProvider'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # add comment
    travel_request.comments.create user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(:selection_requested)

    # todo - doubt(vivek) understand what to be done.
    #travel_request.money_requests.status_pending.update_all(
    #    controlling_user_id: travel_request.controlling_user_id,
    #    controlling_user_role_id: travel_request.controlling_user_role_id
    #)
    # Event::EBankPaymentRequest::Submit.(user, travel_request: travel_request)
    Event::ETravelRequest::RequestSelection.(user, travel_request: travel_request)
    add_message :success, 'Selection has been successfully requested'
  end

  # Check if the user has a selector configured, use the selector. Else the owner becomes the selector
  def travel_booking_selector
    purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
    selector = self.travel_request.user.team_mapping.with_purpose(purpose_id)
                   .policy(self.travel_request.policy_id).default.first&.travel_booking_selector
    if selector.present?
      return [selector, UserRole.id_for(:manager)]
    end
    [self.travel_request.user, UserRole.id_for(:employee)]
  end

end
