class Admin::Cards::AssignRequests::MarkAsAssignedUpgraded < Admin::Cards::AssignRequests::Base

  def process
    self.card_assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:assigned_and_upgraded))
    self.card_assign_request.card.update(card_status_id: CardStatus.id_for(:upgraded))
  end

end