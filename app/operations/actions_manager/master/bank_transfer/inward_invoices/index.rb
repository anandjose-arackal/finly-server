class ActionsManager::Master::BankTransfer::InwardInvoices::Index < ActionsManager::Master::Base

  register_handle :inward_invoices_index
  register_actions [:new_non_po_invoice, :bulk_actions, :approve_non_po_invoices, :reject_non_po_invoices, :control_non_po_invoices, :forward_approval, :export_as_xls, :export_as_csv, :export_all]

  def add_vendor_invoice
    true
  end

  def new_non_po_invoice
    true
  end

  def bulk_actions
    true
  end

  def approve_non_po_invoices
    true
  end

  def reject_non_po_invoices
    true
  end

  def control_non_po_invoices
    true
  end

  def forward_approval
    true
  end

  def export_as_xls
    true
  end

  def export_as_csv
    true
  end

  def export_all
    true
  end

  
end