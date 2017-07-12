class Admin::Cards::AssignRequests::MarkAsAssigned < Admin::Cards::AssignRequests::Base

  def validate
    super
    return if has_errors?
    next_reviewer_presenter = Admin::Cards::AssignRequests::NextAdminReviewPosition.(user, card_assign_request: card_assign_request)
    if next_reviewer_presenter.failure?
      add_message :error, next_reviewer_presenter.messages[:error]
      return
    end
    unless next_reviewer_presenter.is_final?
      add_message :error, 'Card Request cannot be marked as assigned as it has not yet been approved'
      return
    end
    unless [CardAssignRequestStatus.id_for(:processing), CardAssignRequestStatus.id_for(:approved)].include? self.card_assign_request.status_id
      add_message :error, 'Card cannot be approved in this stage'
      return
    end
  end

  def process
    self.card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:assigned))
    self.card_assign_request.card.update(card_status_id: CardStatus.id_for(:assigned))

    track_params = {
        action_resource: user,
        action_id: CardAssignRequestTrackAction.id_for(:assigned)
    }
    self.card_assign_request.tracks.create track_params
  end

end