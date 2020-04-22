class Docs::P2P::PurchaseRequests::Policy < ApplicationPolicy

  def review?
    return false if user.blank?
    return false unless record.purchase_request_status_id == PurchaseRequestStatus.id_for(:awaiting_approval)
    return false unless record.controlling_user?(user)

    true
  end

  def take_control?
    return false if user.blank?
    return false unless record.purchase_request_status_id == PurchaseRequestStatus.id_for(:awaiting_approval)
    return false if record.controlling_user?(user)
    return false unless user.admin?(:vp)

    true
  end

  def destroy?
    return false if user.blank?
    return false unless PurchaseRequestStatus.ids_for(:draft, :rejected, :retracted).include?(record.purchase_request_status_id)
    return false unless record.creator == user

    true
  end

end