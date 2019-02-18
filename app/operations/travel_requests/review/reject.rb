class TravelRequests::Review::Reject < TravelRequests::Review::Base

  attr_accessor :rejection_note

  def init
    super
    self.rejection_note = params[:note]
  end

  def validate
    unless travel_request.can_reject?
      add_message :error, "Travel Request cannot be rejected at this state"
      return
    end

    # unless travel_request.controlling_user_id == user.id
    #   add_message :error, "You cannot reject this travel request"
    #   return
    # end

    if rejection_note.blank?
      add_message :error, 'Please provide a reason for rejection'
      return
    end
  end

  def process
    # current_user_role = nil
    # prev_controlling_user = (travel_request.controlling_user or travel_request.controlling_for_user)
    # prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.travel_request)
    # if travel_request.update status_id: TravelRequestStatus.id_for(:rejected),
    #                          controlling_user_id: travel_request.user_id,
    #                          controlling_user_role_id: UserRole.employee_id,
    #                          controlling_for_user_id: nil,
    #                          controlling_for_user_role_id: nil,
    #                          rejection_note: self.rejection_note
    #   travel_request.travel_request_trails.create action_user: user,
    #                                               action_user_role_id: current_user_role,
    #                                               action_id: TravelRequestTrailAction.id_for(:reject),
    #                                               modified_user: prev_controlling_user,
    #                                               modified_user_role_id: prev_controlling_user_role
    #   return true
    # end
    # add_message :error, travel_request.errors.full_messages
    #  Workflow Manager
    params[:document] = self.travel_request
    params[:aasm_event] = 'reject'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output

    self.trave_request.money_requests.each do |money_request|
      parameters = {
        document: money_request,
        aasm_event: 'reject',
        provider_name: 'TravelRequestProvider'
      }

      money_request_op = WorkflowManager::Base.(user, parameters)
    end
  end

  def post_process
    travel_request.comments.create user_id: user.id,
                                         action_id: TravelRequestCommentAction.id_for(:reject),
                                         note: self.rejection_note

    #travel_request.money_requests.status_pending.update_all(
    #    controlling_user_id: travel_request.controlling_user_id,
    #    controlling_user_role_id: travel_request.controlling_user_role_id
    #)

    # Event::EBankPaymentRequest::Reject.(user, travel_request: travel_request)
    role_id = self.workflow_output[:role_id]
    Event::ETravelRequest::Reject.(user, travel_request: travel_request, role_id: role_id)
    add_message :success, "Travel Request successfully rejected"
  end
end
