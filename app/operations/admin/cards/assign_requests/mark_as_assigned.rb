class Admin::Cards::AssignRequests::MarkAsAssigned < Admin::Cards::AssignRequests::Base

  def process
    self.card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:assigned))
    self.card_assign_request.card.update(card_status_id: CardStatus.id_for(:assigned))
  end

end