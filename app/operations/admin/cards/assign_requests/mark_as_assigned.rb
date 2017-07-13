class Admin::Cards::AssignRequests::MarkAsAssigned < Admin::Cards::AssignRequests::Base

  def validate
    super
    return if has_errors?
    self.card_assign_requests.each do |card_assign_request|
      reviewer_presenter = Admin::Cards::AssignRequests::IsReviewer.(user, card_assign_request: card_assign_request, admin_user: user)
      unless reviewer_presenter.success?
        add_message :error, reviewer_presenter.messages[:error]
        return
      end
      unless reviewer_presenter.is_reviewer
        add_message :error, 'You are not the assigned reviewer for this request'
        return
      end
      unless [CardAssignRequestStatus.id_for(:processing), CardAssignRequestStatus.id_for(:approved)].include? card_assign_request.status_id
        add_message :error, "Error. Card #{card_assign_request.card.proxy} cannot be approved in this stage"
        return
      end
    end
  end

  def process
    self.card_assign_requests.each do |card_assign_request|
      card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:assigned))
      card_assign_request.card.update(card_status_id: CardStatus.id_for(:assigned))
      track_params = {
          action_resource: user,
          action_id: CardAssignRequestTrackAction.id_for(:assigned)
      }
      card_assign_request.tracks.create track_params
    end
  end

end