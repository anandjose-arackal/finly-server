class BankTransfer::InvoiceAttachments::Base < BankTransfer::Base

  def invoice_attachment_params
    params.require(:invoice_attachment).permit(:attached_file, :description)
  end
end