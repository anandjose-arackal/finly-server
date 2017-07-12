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
    end
  end

  def process
    self.card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:rejected), admin_note: params[:admin_note])
  end

end