class BankTransfer::InvoiceAttachments::Destroy < BankTransfer::InvoiceAttachments::Base

  attr_accessor :invoice_attachment

  def init
    id = params[:invoice_attachment_id] || params[:id]
    self.invoice_attachment = user.company.invoice_attachments.find_by(id: id)
  end

  def validate
    if self.invoice_attachment.blank?
      add_message :error, "Invoice attachment not found"
    end
  end

  def process
    unless self.invoice_attachment.destroy
      add_message :error, self.invoice_attachment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice attachment successfully destroyed"
  end
end