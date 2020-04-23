class Docs::PaymentTickets::Policy < ApplicationPolicy

  def review?
    return false if user.blank?
    (record.processing? rescue false) && record.controlling_user?(user)
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)
    (record.processing? rescue false) && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  def mark_as_credited?
    return false unless BankPaymentRequestStatus.ids_for(:open, :retracted, :rejected, :processing, :approved, :auto_approved).include?(record.status_id)
    return false unless user.has_permission?(:bank_payment_request_creditor)

    true
  end

  def credit?
    return false unless BankPaymentRequestStatus.ids_for(:open, :retracted, :rejected, :processing, :approved, :auto_approved).include?(record.status_id)
    return false unless user.has_permission?(:bank_payment_request_creditor)

    true
  end

end