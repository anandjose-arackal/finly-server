class ChangeStatusNameFromClosedToPaidOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    invoice_status = OutwardInvoiceStatus.find_by(name: 'closed')
    invoice_status&.update(name: 'paid')
  end
end
