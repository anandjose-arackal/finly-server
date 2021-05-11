class Masters::Vendors::Policy < ApplicationPolicy

  action :create? do
    user.has_permission?([:vendor_creator, :vendor_manager]) || user.vendor_payment_admin? || user.permission.create_beneficiaries
  end

  # def create?
  #   user.has_permission?([:vendor_creator, :vendor_manager]) || user.vendor_payment_admin? || user.permission.create_beneficiaries
  # end

  action :submit? do
    record.created_by_id == user.id && (YesBankVendor.status_ids(:retracted, :rejected, :draft).include? record.status_id)
  end

  action :show? do
    (user.company_id == record.company_id && YesBankVendor.status_ids(:approved, :auto_approved).include?(record.status_id)) ||
      (user.is_vendor_initiator? && record.created_by_id == user.id) || user.has_permission?([:vendor_manager, :vendor_auditor]) || user.vendor_payment_admin? ||
      (record.document_level_reviewer_mappings.map(&:reviewer).include?(user))
  end

  action :update? do
    (user.has_permission?([:vendor_manager]) || user.vendor_payment_admin? || user.permission.create_beneficiaries) || (record.created_by_id == user.id && YesBankVendor.status_ids(:retracted, :draft, :rejected).include?(record.status_id)) || (record.get_reviewers.include?(user) && record.awaiting_approval?)
  end

  action :review? do
    return false if user.blank?
    record.awaiting_approval? && record.controlling_user?(user)
  end

  action :take_control? do
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)
    record.awaiting_approval? && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  action :vendor_forms_enabled? do
    FormsVendorToggle.new(user).enabled?
  end

end