class TravelRequests::Review::RejectSelection < TravelRequests::Review::ConfirmSelection

  protected
  def trail_action_id
    TravelRequestTrailAction.id_for(:selection_approved)
  end

end