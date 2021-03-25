class Masters::Vendors::Policy < ApplicationPolicy

  def create
    user.is_vendor_initiator? || user.is_vendor_manager? || user.vendor_payments_admin? || user.permission.create_beneficiaries
  end

  def submit
    record.created_by_id == user.id && (YesBankVendor.status_ids(:retracted, :rejected, :draft).include? record.status_id)  
  end

  def show?
    # Todo condition to check if user can view the document. Currently scoping it to admin for test pu
    (user.is_vendor_initiator? && record.created_by_id == user.id ) || user.is_vendor_manager? || user.vendor_payments_admin? || user.permission.create_beneficiaries || (record.get_reviewers.include?(user) && record.awaiting_approval?)
  end

  def update
    (user.is_vendor_manager? || user.vendor_payment_admin? || user.permission.create_beneficiaries) || (record.created_by_id == user.id && YesBankVendor.status_ids(:retracted, :draft, :rejected).include?(record.status_id)) || (record.get_reviewers.include?(user) && record.awaiting_approval?)
  end

  def review?
    return false if user.blank?

    record.awaiting_approval? && record.controlling_user?(user)
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)
    record.awaiting_approval? && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  def vendor_forms_enabled?
    FormsVendorToggle.new(user).enabled?
  end

end