class Invoicing::Invoice::UploadAttachment < Invoicing::Invoice::Base
  attr_accessor :attachment_parameters, :outward_invoice_attachment

  class Invoicing::Invoice::UploadAttachment::AttachmentPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachment

    def init
      self.attachment = params[:outward_invoice_attachment]
    end
  end

  def init
    # id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    # self.invoice = user.company.outward_invoices.find_by(id: id)
    self.attachment_parameters = attachment_params
  end

  def validate
    # if self.invoice.blank?
    #   add_message :error, "Invoice not found"
    #   return
    # end
    #
    # unless self.invoice.editable?
    #   add_message :error, "This invoice cannot be edited"
    # end
  end

  def pre_process

    self.attachment_parameters[:user_id] = user.id
  end

  def process
    self.outward_invoice_attachment = user.company.outward_invoice_attachments.build(attachment_parameters)

    unless outward_invoice_attachment.save
      add_message :error, outward_invoice_attachment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Attachment Uploaded"
  end

  def success
    params[:outward_invoice_attachment] = self.outward_invoice_attachment
    Invoicing::Invoice::UploadAttachment::AttachmentPresenter.new(user, params, messages)
  end

  private

  def attachment_params
    params.require(:invoice).permit(:attachment, :description)
  end

end