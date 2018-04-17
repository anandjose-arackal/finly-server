class TravelRequests::Review::Retract < TravelRequests::Review::Base

  def authorized_user_types
    [:employee]
  end

  def validate
    unless travel_request.owner_id == user.id
      add_message :error, "Only Owners can retract their report"
      return
    end

    unless travel_request.can_retract?
      add_message :error, "Payment Order cannot be retracted in this state"
      return
    end
  end

  def process

    if travel_request.update status_id: TravelRequestStatus.id_for(:retracted),
                             controlling_user_id: user.id,
                             controlling_user_role_id: UserRole.id_for(:employee),
                             controlling_for_user_id: nil,
                             controlling_for_user_role_id: nil
      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: UserRole.id_for(:employee),
                                                  action_id: TravelRequestTrailAction.id_for(:retract)
      return true
    end
    add_message :error, travel_request.errors.full_messages
  end

  def post_process
    # add comments
    # travel_request.comments.create user_id: user.id,
    #                                      action_id: BankPaymentRequestCommentAction.id_for(:retract)
    #
    #
    # Event::EBankPaymentRequest::Retract.(user, travel_request: travel_request)
    add_message :success, "Travel Request retracted successfully"
  end

end