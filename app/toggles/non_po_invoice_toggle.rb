class NonPoInvoiceToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/non_po_invoice#forms_enabled', true
  end

end