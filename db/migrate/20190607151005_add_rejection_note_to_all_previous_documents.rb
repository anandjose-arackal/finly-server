class AddRejectionNoteToAllPreviousDocuments < ActiveRecord::Migration[5.2]
  def change
    PurchaseOrder.where(purchase_order_status_id: PurchaseOrderStatus.id_for(:rejected)).each do |po|
      reject_trail = po.trails.where(action_id: TrailAction.id_for(:reject)).reorder(created_at: :desc).first
      rejection_note = reject_trail.note
      po.update(rejection_note: rejection_note)
    end

    Invoice.where(invoice_status_id: InwardInvoiceStatus.id_for(:rejected)).each do |invoice|
      reject_trail = invoice.trails.where(action_id: TrailAction.id_for(:reject)).reorder(created_at: :desc).first
      rejection_note = reject_trail.note
      invoice.update(rejection_note: rejection_note)
    end
  end
end