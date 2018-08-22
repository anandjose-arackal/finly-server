class TravelRequests::Review::ConfirmBooking < TravelRequests::Review::Base
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
    unless self.travel_request.controlling_user_id == user.id
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
    unless travel_manager_view?
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
    unless user.travel_manager?
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
    unless travel_request.booking_pending? or travel_request.processing? or travel_request.selection_confirmed?
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
    unless travel_request.bookings.confirmed.present?
      add_message :error, 'Please add atleast one booking to mark as completed'
    end
    # todo status validation
    # validate if necessary booking requests with unselected options are available
  end

  def process
    if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:booking_confirmed),
                                        controlling_user_id: nil,
                                        controlling_user_role_id: nil,
                                        booking_confirmed_at: DateTime.now

      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: UserRole.id_for(:travel_manager),
                                                  action_id: TravelRequestTrailAction.id_for(:booking_confirmed),
                                                  modified_user_id: user,
                                                  modified_user_role_id: UserRole.id_for(:travel_manager)
      return true
    end
    add_message :error, travel_request.errors.full_messages
  end

  def post_process
    # add comment
    travel_request.comments.create user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(:booking_confirmed)
    # Event::EBankPaymentRequest::Submit.(user, travel_request: travel_request)
    add_message :success, 'Selection has been successfully requested'

    set_money_request_as_approved
  end

  def set_money_request_as_approved
    return if travel_request.money_requests.blank?
    finance_manager = User::Team::Approver.(travel_request.user, money_request: travel_request.money_requests.first, type: :finance_manager)
    role_id = finance_manager.present? ? UserRole.id_for(:finance) : nil
    travel_request.money_requests.update_all(status_id: MoneyRequestStatus.id_for(:approved), controlling_user: finance_manager, controlling_user_role_id: role_id)
  end

end