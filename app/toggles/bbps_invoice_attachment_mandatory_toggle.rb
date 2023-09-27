class BbpsInvoiceAttachmentMandatoryToggle < ApplicationToggle

  def enabled?
    feature_flag 'feature/bbps_invoice_attachment_mandatory', true
  end
end