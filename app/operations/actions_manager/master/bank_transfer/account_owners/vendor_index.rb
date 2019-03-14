class ActionsManager::Master::BankTransfer::AccountOwners::VendorIndex < ActionsManager::Master::Base

  register_handle :beneficiaries_vendor_index
  register_actions [:create_vendor, :create_payment_order, :import_vendor, :export_vendor]

  def create_vendor
    user.vendor_payments_admin? || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:vendor_creator)) || user.has_policy_role?(UserRole.id_for(:vendor_manager))
  end

  def create_payment_order
    user.vendor_payments_admin? || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def import_vendor
    user.vendor_payments_admin? || user.has_policy_role?(UserRole.id_for(:vendor_creator)) || user.has_policy_role?(UserRole.id_for(:vendor_manager))
  end

  def export_vendor
    user.vendor_payments_admin? || user.has_policy_role?(UserRole.id_for(:vendor_creator)) || user.has_policy_role?(UserRole.id_for(:vendor_manager))
  end

end