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

    unless travel_request.controlling_user_id == user.id
      add_message :error, "You cannot reject this travel request"
      return
    end
  end

  def process
    current_user_role = nil
    if travel_request.update status_id: TravelRequestStatus.id_for(:rejected),
                             controlling_user_id: travel_request.owner_id,
                             controlling_user_role_id: UserRole.employee_id,
                             controlling_for_user_id: nil,
                             controlling_for_user_role_id: nil,
                             rejection_note: self.rejection_note
      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: current_user_role,
                                                  action_id: TravelRequestTrailAction.id_for(:reject),
                                                  modified_user_id: travel_request.owner_id,
                                                  modified_user_role_id: UserRole.employee_id
      return true
    end
    add_message :error, travel_request.errors.full_messages
  end

  def post_process
    # add comments #todo
    # travel_request.comments.create user_id: user.id,
    #                                      action_id: BankPaymentRequestCommentAction.id_for(:reject),
    #                                      note: rejection_note

    # Event::EBankPaymentRequest::Reject.(user, travel_request: travel_request)

    add_message :success, "Payment Request successfully rejected"
  end

end