class ActionsManager::Master::BankTransfer::AccountOwners::VendorIndex < ActionsManager::Master::Base

  register_handle :beneficiaries_vendor_index
  register_actions [:create_vendor, :create_payment_order, :import_vendor, :export_vendor]

  def create_vendor
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def create_payment_order
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def import_vendor
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

  def export_vendor
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end

end