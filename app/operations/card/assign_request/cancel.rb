class Card::AssignRequest::Cancel < Card::AssignRequest::Base
  attr_accessor :card_assign_request

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if params&.dig(:id).blank? and params&.dig(:card_assign_request_id).blank?
      add_message :error ,'Card Assign Request not found'
      return
    end
  end

  def init
    show_presenter = Card::AssignRequest::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.card_assign_request = show_presenter.card_assign_request
  end

  def validate
    if self.card_assign_request.blank?
      add_message :error, 'Card Assign Request not found'
      return
    end
    unless self.card_assign_request.cancellable?
      add_message :error,'Card Assign Request cannot be cancelled at this stage'
      return
    end
  end

  def process
    unless self.card_assign_request.update(status_id: CardAssignRequestStatus.id_for(:cancelled))
      add_message :error, self.card_assign_request.errors.full_messages
      return
    end
    card_assign_request.card.update(user_id: nil, card_program_id: nil, card_status_id: CardStatus.id_for(:unassigned))
    track_params = {
        action_resource: user,
        action_id: CardAssignRequestTrackAction.id_for(:cancel)
    }
    self.card_assign_request.tracks.create track_params
  end

end