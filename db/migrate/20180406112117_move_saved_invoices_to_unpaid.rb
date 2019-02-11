class MoveSavedInvoicesToUnpaid < ActiveRecord::Migration[4.2]
  def change
    OutwardInvoice.saved.all.each do |invoice|
      invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:unpaid))
    end
  end
end
