class AddAwaitingApprovalStatuses < ActiveRecord::Migration[6.0]
  def change
    InwardInvoiceStatus.create({name: 'awaiting_approval'})
    PurchaseOrderStatus.create({name: 'awaiting_approval'})
    PurchaseRequestStatus.create({name: 'processing'})
  end
end
