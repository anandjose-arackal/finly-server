class Docs::P2P::PurchaseOrders::Policy < ApplicationPolicy

  def create_grn?
    false
  end

  def review?
    return false if user.blank?

    (record.processing? rescue false) && record.controlling_user?(user)
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)
    (record.processing? rescue false) && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

end