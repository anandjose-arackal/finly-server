class Docs::P2P::PurchaseOrders::Policy < ApplicationPolicy

  def show?
    user.present? && record.company_id == user.company.id
  end

  def update?
    return false unless user
    return true if user.vendor_payment_admin? && record.processing?
    if po_modifiable? && !record.procurement.po_revisions.pluck(:revision_of_id).include?(record.id)
      # Admin
      (user.vendor_payment_admin? && (!record.voided? && !record.approved? && !record.auto_approved? && !record.closed? && !record.sent_to_vendor? && !record.vendor_confirmed?) &&
      !((record.open? || record.retracted? || record.rejected?))) ||
      # Doc owner
      (document_owner? && (record.open? || record.retracted? || record.rejected?)) ||
      # Reviewer
      (record.processing? && document_reviewer?)
    end
    true
  end

  def submit?
    return false unless user
    if user.is_purchase_order_initiator? || user.vendor_payments_admin?
      return document_owner? && (record.open? || record.retracted? || record.rejected?)
    end
    false
  end

  def save_and_submit?
    update? && submit?
  end

  def create_grn?
    return false unless user
    return (record.approved? || record.auto_approved?) && (document_reviewer? || document_owner? || user.vendor_payments_admin?)
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

  private

  def document_owner?
    record.user_id.eql?(user.id)
  end

  def document_reviewer?
    record.get_reviewers.include?(user)
  end

  def po_modifiable?
    (record.procurement.invoices.blank? && record.procurement.inward_documents.blank?)
  end
end