class BankTransfer::InvoiceAttachments::Create < BankTransfer::InvoiceAttachments::Base

  attr_accessor :invoice_attachment, :inward_invoice, :attachment_parameters

  class BankTransfer::InvoiceAttachments::Create::AttachmentPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice_attachment

    def init
      self.invoice_attachment = params[:invoice_attachment]
    end
  end

  def init
    id = params[:id] | params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = Invoice.find_by(id: id)
    self.attachment_parameters = attachment_params
  end

  def process
    self.invoice_attachment = self.inward_invoice.invoice_attachments.build(self.attachment_parameters)
    unless self.invoice_attachment.save
      add_message :error, self.invoice_attachment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Attachment created!"
  end
end