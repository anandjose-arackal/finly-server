class BankTransfer::InvoiceAttachments::Index < BankTransfer::InvoiceAttachments::Base

  attr_accessor :invoice_attachments

  class BankTransfer::InvoiceAttachments::Index::InvoiceAttachmentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice_attachments

    def init
      self.invoice_attachments = params[:invoice_attachments]
    end
  end

  def init
    self.invoice_attachments = user.company.invoice_attachments.without_parent
  end

  def success
    params[:invoice_attachments] = self.invoice_attachments
    BankTransfer::InvoiceAttachments::Index::InvoiceAttachmentsPresenter.new(user, params, messages)
  end
end