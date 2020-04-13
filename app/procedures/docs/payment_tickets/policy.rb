class Docs::PaymentTickets::Policy < ApplicationPolicy

  def create?
    true
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def show?
    owner?
  end

  def approve?
    return false if user.blank?
    (record.processing? rescue false) && record.get_reviewers.include?(user)
  end

  def reject?
    approve?
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)
    (record.processing? rescue false) && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  def owner?
    record.user == user
  end

end