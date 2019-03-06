class ActionsManager::Master::BankTransfer::AccountOwners::EmployeeIndex < ActionsManager::Master::Base

  register_handle :beneficiaries_employee_index
  register_actions [:create_payment_order, :import_vendors, :export_vendors, :xls, :csv]

  def create_payment_order
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

  def import_vendors
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

  def export_vendors
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

  def xls
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end

  def csv
    user.vendor_payments_admin? || user.vendor_payments_initiator?
  end
end