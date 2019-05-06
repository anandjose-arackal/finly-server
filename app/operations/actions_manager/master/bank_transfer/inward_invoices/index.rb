class ActionsManager::Master::BankTransfer::InwardInvoices::Index < ActionsManager::Master::Base

  register_handle :inward_invoices_index
  register_actions [:new_non_po_invoice, :bulk_non_po_actions, :approve_non_po_invoices, :reject_non_po_invoices, :control_non_po_invoices, :forward_non_po_approval, :export_non_po_as_csv, :export_non_po_as_xls, :export_all_non_po, :approve_po_invoices, :control_po_invoices, :reject_po_invoices, :forward_po_approval, :export_po_as_xls, :export_po_as_csv]

  def new_non_po_invoice
    user.is_invoice_initiator??
  end

  def bulk_non_po_actions
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def approve_non_po_invoices
    user.is_invoice_reviewer? || user.vendor_payments_admin?
  end

  def reject_non_po_invoices
    user.is_invoice_reviewer? || user.vendor_payments_admin?
  end

  def control_non_po_invoices
    user.vendor_payments_admin?
  end

  def forward_non_po_approval
    user.is_invoice_reviewer? || user.vendor_payments_admin?
  end

  def export_non_po_as_xls
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def export_non_po_as_csv
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def export_all_non_po
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def approve_po_invoices
    user.is_invoice_reviewer? || user.vendor_payments_admin?
  end

  def control_po_invoices
    user.vendor_payments_admin?
  end

  def reject_po_invoices
    user.is_invoice_reviewer? || user.vendor_payments_admin?
  end

  def forward_po_approval
    user.is_invoice_reviewer? || user.vendor_payments_admin?
  end

  def export_po_as_xls
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def export_po_as_csv
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def bulk_po_actions
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  def export_all_po
    user.is_invoice_reviewer? || user.vendor_payments_admin? || user.is_invoice_initiator?
  end

  
end