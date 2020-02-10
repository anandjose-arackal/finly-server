class ActionsManager::Master::Vendors::Index < ActionsManager::Master::Base
  register_handle :vendors_index
  register_actions %i( create bulk_actions export_all bulk_actions bulk_approve bulk_control bulk_reject export_as_xls export_as_csv )


  def create
    user.is_vendor_initiator? || user.is_vendor_manager? || user.vendor_payments_admin? || user.permission.create_beneficiaries
  end

  def export_all
    true
  end

  def bulk_actions
    user.company.vendor_empanelment_workflow_enabled? && (user.vendor_payments_admin? || user.is_vendor_reviewer? || user.is_vendor_manager?)
  end

  def bulk_actions
    true
  end

  def bulk_approve
    user.vendor_payments_admin? || user.is_vendor_reviewer?
  end

  def bulk_control
    user.vendor_payments_admin?
  end

  def bulk_reject
    user.vendor_payments_admin? || user.is_vendor_reviewer?
  end

  def export_as_xls
    true
  end

  def export_as_csv
    true
  end
end