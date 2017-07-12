class Admin::Cards::AssignRequests::Reject < Admin::Cards::AssignRequests::Base

  def validate
    super
    return if has_errors?
    reviewer_presenter = Admin::Cards::AssignRequests::IsReviewer.(user, card_assign_request: card_assign_request, admin_user: user)
    unless reviewer_presenter.success?
      add_message :error, reviewer_presenter.messages[:error]
      return
    end
    unless reviewer_presenter.is_reviewer
      add_message :error, 'You are not the assigned reviewer for this request'
      return
    end
    unless [CardAssignRequestStatus.id_for(:processing),
            CardAssignRequestStatus.id_for(:approved)].include? self.card_assign_request.status_id
      add_message :error, 'Card cannot be rejected in this stage'
      return
    end
  end

  def process
    self.card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:rejected), admin_note: params[:admin_note])

    track_params = {
        action_resource: user,
        action_id: CardAssignRequestTrackAction.id_for(:reject),
        note: params[:admin_note]
    }
    self.card_assign_request.tracks.create track_params
  end

end