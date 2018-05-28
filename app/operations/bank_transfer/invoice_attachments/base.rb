class BankTransfer::InvoiceAttachments::Base < BankTransfer::Base

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters passed"
    end
  end

  def invoice_attachment_params
    params.require(:invoice_attachment).permit(:attached_file, :description)
  end
end