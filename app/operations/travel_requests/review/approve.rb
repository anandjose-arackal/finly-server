class TravelRequests::Review::Approve < TravelRequests::Review::Base

  attr_accessor :auto_approve

  def authorized_user_type
    [:manager, :finance_manager, :admin]
  end

  def init
    super
    self.auto_approve = params[:auto_approve]
  end

  def validate
    # unless travel_request.controlling_user_id == user.id
    #   add_message :error, 'You are not eligible to perform this action'
    #   return
    # end

    unless travel_request.can_approve? || params[:auto_approve]
      add_message :error, 'Travel Request cannot be approved in this state'
      return
    end
  end

  def process
    # presenter = User::Team::Review::NextReviewer.(travel_request)
    # next_reviewer = presenter.user
    # next_reviewer_role_id = presenter.role_id
    # # this returns the role under which this particular user is viewing the payment request
    # current_user_role = User::Team::Review::UserRole.(user, self.travel_request)
    # if next_reviewer.nil?
    #   travel_request_status = TravelRequestStatus.id_for(:approved)
    # elsif next_reviewer_role_id == UserRole.id_for(:travel_manager)
    #   travel_request_status = TravelRequestStatus.id_for(:booking_pending)
    # else
    #   travel_request_status = TravelRequestStatus.id_for(:processing)
    # end
    # action_for_user_id = travel_request.controlling_for_user_id
    # action_for_user_role_id = travel_request.controlling_for_user_role_id
    # if travel_request.update status_id: travel_request_status,
    #                          controlling_user: next_reviewer,
    #                          controlling_user_role_id: next_reviewer_role_id,
    #                          controlling_for_user_id: nil,
    #                          controlling_for_user_role_id: nil,
    #                          auto_approved: self.auto_approve
    #   travel_request.travel_request_trails.create action_user: user,
    #                                                           action_user_role_id: current_user_role,
    #                                                           action_for_user_id: action_for_user_id,
    #                                                           action_for_user_role_id: action_for_user_role_id,
    #                                                           action_id: TravelRequestTrailAction.id_for(:approve),
    #                                                           modified_user_id: next_reviewer&.id,
    #                                                           modified_user_role_id: next_reviewer_role_id
    #   return true
    # end
    # add_message :error, travel_request.errors.full_messages

    ###################
    # NEW CODE
    #  Workflow Manager
    params[:document] = self.travel_request
    params[:aasm_event] = 'approve'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output

    self.travel_request.money_requests.each do |money_request|
      parameters = {
        document: money_request,
        aasm_event: 'approve',
        provider_name: 'TravelRequestProvider'
      }

      money_request_op = WorkflowManager::Base.(user, parameters)
    end
    # NEW CODE ENDS
    ####################
  end

  def post_process
    if self.auto_approve
      action_id = TravelRequestCommentAction.id_for(:auto_approve)
    else
      action_id = TravelRequestCommentAction.id_for(:approve)
    end
    self.travel_request.comments.create user_id: user.id,
                                         action_id: action_id


    #travel_request.money_requests.status_pending.update_all(
    #    controlling_user_id: travel_request.controlling_user_id,
    #    controlling_user_role_id: travel_request.controlling_user_role_id
    #)
    #
    # Event::EBankPaymentRequest::Approve.(user, travel_request: travel_request)
    # Notifications
    role_id = self.workflow_output[:role_id]
    Event::ETravelRequest::Approve.(user, travel_request: travel_request, role_id: role_id)
    add_message :success, 'Succesfully approved the travel request'
  end

end
