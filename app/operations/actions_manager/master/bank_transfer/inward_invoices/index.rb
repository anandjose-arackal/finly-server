class ActionsManager::Master::BankTransfer::InwardInvoices::Index < ActionsManager::Master::Base

  register_handle :inward_invoices_index
  register_actions [:new_non_po_invoice, :bulk_actions, :approve_non_po_invoices, :reject_non_po_invoices, :control_non_po_invoices, :forward_non_po_approval, :export_non_po_as_csv, :export_non_po_as_xls, :export_all, :approve_po_invoices, :control_po_invoices, :reject_po_invoices, :forward_po_approval, :export_po_as_xls, :export_po_as_csv]

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

  def forward_non_po_approval
    true
  end

  def export_non_po_as_xls
    true
  end

  def export_non_po_as_csv
    true
  end

  def export_all
    true
  end

  def approve_po_invoices
    true
  end

  def control_po_invoices
    true
  end

  def reject_po_invoices
    true
  end

  def forward_po_approval
    true
  end

  def export_po_as_xls
    true
  end

  def export_po_as_csv
    true
  end

  
end