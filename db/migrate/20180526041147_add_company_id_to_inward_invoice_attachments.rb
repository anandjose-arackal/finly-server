class AddCompanyIdToInwardInvoiceAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_attachments, :company_id, :integer, references: "Company", foreign_key: true, index: true

    # attaching company id to all existing invoice attachments
    InvoiceAttachment.all.each do |invoice_attachment|
      company_id = invoice_attachment.invoice.payments.first&.company_id
      invoice_attachment.update(company_id: company_id)
    end
  end
end
