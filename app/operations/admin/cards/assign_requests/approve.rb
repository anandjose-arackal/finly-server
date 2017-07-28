class Admin::Cards::AssignRequests::Approve < Admin::Cards::AssignRequests::Base

  def validate
    super
    return if has_errors?
    self.card_assign_requests.each do |card_assign_request|
      reviewer_presenter = Admin::Cards::AssignRequests::Accessable.(user, card_assign_request: card_assign_request, admin_user: user)
      unless reviewer_presenter.success?
        add_message :error, reviewer_presenter.messages[:error]
        return
      end
      unless reviewer_presenter.is_reviewer
        add_message :error, 'You are not the assigned reviewer for this request'
        return
      end
      unless [CardAssignRequestStatus.id_for(:processing)].include? card_assign_request.status_id
        add_message :error, "Error. Card #{card_assign_request.card.proxy} cannot be approved in this stage"
        return
      end
    end
  end

  def process
    self.card_assign_requests.each do |card_assign_request|
      next_reviewer_presenter = Admin::Cards::AssignRequests::NextAdminReviewPosition.(user, card_assign_request: card_assign_request)
      if next_reviewer_presenter.failure?
        add_message :error, next_reviewer_presenter.messages[:error]
        return
      end
      if next_reviewer_presenter.is_final?
        # No more reviewers
        card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:approved))

        track_params = {
            action_resource: user,
            action_id: CardAssignRequestTrackAction.id_for(:final_approve)
        }
        card_assign_request.tracks.create track_params
      else
        next_reviewer_position = next_reviewer_presenter.next_review_position
        card_assign_request.update(review_position: next_reviewer_position)

        track_params = {
            action_resource: user,
            action_id: CardAssignRequestTrackAction.id_for(:approve)
        }
        card_assign_request.tracks.create track_params
      end
    end
  end

end