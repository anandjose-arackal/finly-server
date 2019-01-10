class AddCompanyIdToOutwardInvoiceAttachment < ActiveRecord::Migration[4.2]
  def change
    add_reference :outward_invoice_attachments, :company, index: true, foreign_key: true
    add_reference :outward_invoice_attachments, :user, index: true, foreign_key: true
  end
end
