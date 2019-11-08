class UpdatePurchaseRequestStatusPostApproved < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequest.where(purchase_request_status_id: PurchaseRequestStatus.id_for(:po_created)).each do |purchase_request|

    # If all rejected, reject purchase request status
      if purchase_request.purchase_request_items.where.not(status_id: PurchaseRequestItemStatus.id_for(:rejected)).blank?
        purchase_request.update(purchase_request_status_id:  PurchaseRequestStatus.id_for(:rejected))
        break
      end


      if purchase_request.purchase_request_items.where.not(status_id: [PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:closed)]).blank?
        purchase_request.update(purchase_request_status_id:  PurchaseRequestStatus.id_for(:closed))
        break
      end

      # if purchase_request.purchase_request_items.where(status_id: [PurchaseRequestItemStatus.id_for(:rejected), PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:closed)]).present?
      #   purchase_request.update(purchase_request_status_id:  PurchaseRequestStatus.id_for(:partially_closed))
      #   break
      # end

      if purchase_request.purchase_request_items.where(status_id: PurchaseRequestItemStatus.id_for(:po_created)).where.not(status_id: [PurchaseRequestItemStatus.id_for(:draft), PurchaseRequestItemStatus.id_for(:awaiting_approval), PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved), PurchaseRequestItemStatus.id_for(:retracted), PurchaseRequestItemStatus.id_for(:closed)]).present?
        purchase_request.update(purchase_request_status_id:  PurchaseRequestStatus.id_for(:approved))
        break
      end
    end
  end
end
