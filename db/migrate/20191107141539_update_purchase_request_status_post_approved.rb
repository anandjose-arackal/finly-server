class UpdatePurchaseRequestStatusPostApproved < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequest.where(purchase_request_status_id: PurchaseRequestStatus.id_for(:po_created)).each do |purchase_request|

      # close line items
      if purchase_request.purchase_request_items.where.not(status_id: PurchaseRequestItemStatus.id_for(:po_created)).blank?
        purchase_request.purchase_request_items.each do |item|
          if item&.purchase_order.present? && item&.purchase_order&.closed?
            if item.status_id == PurchaseRequestItemStatus.id_for(:po_created)
              item.update(status_id: PurchaseRequestItemStatus.id_for(:po_closed))
            end
          end
        end
      end

      # If all rejected, reject purchase request status
      if purchase_request.purchase_request_items.where.not(status_id: PurchaseRequestItemStatus.id_for(:rejected)).blank?
        purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:rejected))
        next
      end


      if purchase_request.purchase_request_items.where.not(status_id: [PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:closed)]).blank?
        purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:closed))
        next
      end

      # if purchase_request.purchase_request_items.where(status_id: [PurchaseRequestItemStatus.id_for(:rejected), PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:closed)]).present?
      #   purchase_request.update(purchase_request_status_id:  PurchaseRequestStatus.id_for(:partially_closed))
      #   next
      # end

      if purchase_request.purchase_request_items.where(status_id: PurchaseRequestItemStatus.id_for(:po_created)).where.not(status_id: [PurchaseRequestItemStatus.id_for(:draft), PurchaseRequestItemStatus.id_for(:awaiting_approval), PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved), PurchaseRequestItemStatus.id_for(:retracted), PurchaseRequestItemStatus.id_for(:closed)]).present?
        purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:approved))
        next
      end

      if purchase_request.purchase_request_items.where.not(status_id: [PurchaseRequestItemStatus.id_for(:po_closed), PurchaseRequestItemStatus.id_for(:rejected)]).blank?
        if purchase_request.purchase_request_status_id == PurchaseRequestStatus.id_for(:po_created)
          purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:closed))
        end
      end

    end
  end
end
