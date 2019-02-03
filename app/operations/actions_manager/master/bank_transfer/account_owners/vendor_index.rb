class ActionsManager::Master::BankTransfer::AccountOwners::VendorIndex < ActionsManager::Master::Base

  register_handle :beneficiaries_vendor_index
  register_actions [:create_vendor, :create_payment_order, :import_vendor, :export_vendor]

  def create_vendor
    user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_auditor? || user.vendor_payments_initiator?
  end

  def create_payment_order
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

  def import_vendor
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

  def export_vendor
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

end