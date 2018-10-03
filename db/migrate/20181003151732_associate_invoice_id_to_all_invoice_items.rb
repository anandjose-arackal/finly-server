class AssociateInvoiceIdToAllInvoiceItems < ActiveRecord::Migration
  def change
    InvoiceLineItem.all.each do |invoice_line_item|
      invoice = invoice_line_item.parent
      invoice_line_item.update(invoice_id: invoice.id)
    end
  end
end
