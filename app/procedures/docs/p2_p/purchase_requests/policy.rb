class Docs::P2P::PurchaseRequests::Policy < ApplicationPolicy

  def approve?
    return false if user.blank?

    (record.purchase_request_status_id == PurchaseRequestStatus.id_for(:awaiting_approval)) && record.controlling_user?(user)
  end

end