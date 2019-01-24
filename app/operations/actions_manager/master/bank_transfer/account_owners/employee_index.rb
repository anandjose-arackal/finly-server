class ActionsManager::Master::BankTransfer::AccountOwners::EmployeeIndex < ActionsManager::Master::Base

  register_handle :beneficiaries_employee_index
  register_actions [:create_payment_order, :import_vendors, :export_vendors, :xls, :csv]

  def create_payment_order
    true
  end

  def import_vendors
    true
  end

  def export_vendors
    true
  end

  def xls
    true
  end

  def csv
    true
  end
end