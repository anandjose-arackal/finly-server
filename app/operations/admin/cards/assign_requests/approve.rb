class Admin::Cards::AssignRequests::Approve < Admin::Cards::AssignRequests::Base

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
    unless [CardAssignRequestStatus.id_for(:processing)].include? self.card_assign_request.status_id
      add_message :error, 'Card cannot be approved in this stage'
      return
    end
  end

  def process
    next_reviewer_presenter = Admin::Cards::AssignRequests::NextAdminReviewPosition.(user, card_assign_request: card_assign_request)
    if next_reviewer_presenter.failure?
      add_message :error, next_reviewer_presenter.messages[:error]
      return
    end
    if next_reviewer_presenter.is_final?
      # No more reviewers
      self.card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:approved))

      track_params = {
          action_resource: user,
          action_id: CardAssignRequestTrackAction.id_for(:final_approve)
      }
      self.card_assign_request.tracks.create track_params
    else
      next_reviewer_position = next_reviewer_presenter.next_review_position
      self.card_assign_request.update(review_position: next_reviewer_position)

      track_params = {
          action_resource: user,
          action_id: CardAssignRequestTrackAction.id_for(:approve)
      }
      self.card_assign_request.tracks.create track_params
    end
  end

end