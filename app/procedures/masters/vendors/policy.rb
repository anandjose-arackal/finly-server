class Masters::Vendors::Policy < ApplicationPolicy


  def review?
    return false if user.blank?

    record.awaiting_approval? && record.controlling_user?(user)
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)
    record.awaiting_approval? && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

end