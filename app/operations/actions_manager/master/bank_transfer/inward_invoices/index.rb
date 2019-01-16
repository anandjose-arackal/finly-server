class ActionsManager::Master::BankTransfer::InwardInvoices::Index < ActionsManager::Master::Base

  register_handle :inward_invoices_index

  register_actions [:add_vendor_invoice]

  def add_vendor_invoice
    user.admin?
  end

  
end