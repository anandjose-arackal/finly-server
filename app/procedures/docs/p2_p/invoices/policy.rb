class Docs::P2P::Invoices::Policy < ApplicationPolicy

  def create?
    user.present?
  end

  def review?
    return false if user.blank?

    record.processing? && record.controlling_user?(user)
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)

    record.processing? && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

end