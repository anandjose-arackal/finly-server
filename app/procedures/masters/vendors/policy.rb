class Masters::Vendors::Policy < ApplicationPolicy

  def show?
    # Todo condition to check if user can view the document. Currently scoping it to admin for test pu
    user.admin?
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