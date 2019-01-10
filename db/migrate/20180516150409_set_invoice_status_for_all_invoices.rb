class SetInvoiceStatusForAllInvoices < ActiveRecord::Migration[4.2]
  def change
    Invoice.all.each do |invoice|
      payment = invoice.payments.first
      if payment&.completed?
        invoice.update(invoice_status_id: InwardInvoiceStatus.id_for(:paid))
      else
        invoice.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
      end
    end
  end
end