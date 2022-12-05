class PoInvoiceToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/po_invoice#forms_enabled', false
  end

  def bulk_import_enabled?
    feature_flag 'release/po_invoice#bulk_import_enabled', false
  end
end