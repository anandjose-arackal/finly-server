class AssociateInvoiceIdToAllInvoiceItems < ActiveRecord::Migration[4.2]
  def change
    InvoiceLineItem.all.each do |invoice_line_item|
      invoice = invoice_line_item.parent
      if invoice.is_a?(Invoice)
        invoice_line_item.update(invoice_id: invoice.id)
      end
    end
  end
end
