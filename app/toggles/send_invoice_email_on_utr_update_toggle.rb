class SendInvoiceEmailOnUtrUpdateToggle < ApplicationToggle
  def enabled?
    feature_flag 'feature/send_invoice_email_on_utr_update#enabled', false
  end
end
