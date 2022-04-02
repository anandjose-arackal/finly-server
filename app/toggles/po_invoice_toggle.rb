class PoInvoiceToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/po_invoice#forms_enabled', false
  end

end