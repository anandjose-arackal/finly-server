class MinimalInvoiceUiToggle < ApplicationToggle

  def minimal_invoice_ui_enabled?
    feature_flag 'permissions/minimal_invoice_ui#enabled', false
  end

end