class ChangeStatusNameFromClosedToPaidOutwardInvoice < ActiveRecord::Migration
  def change
    invoice_status = OutwardInvoiceStatus.find_by(name: 'closed')
    invoice_status&.update(name: 'paid')
  end
end
