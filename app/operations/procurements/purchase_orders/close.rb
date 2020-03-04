class Procurements::PurchaseOrders::Close < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:purchase_order_id] || params[:id] 
    self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'close'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
  end

  def post_process
    add_message :success, 'Successfully Closed Purchase Order'
    update_purchase_request_status
    update_purchase_order_advance
  end

  def update_purchase_request_status
    # TODO - Add scopes w.r.t. pr status
    if purchase_order.purchase_request_items.present?
      close_purchase_request_items
      # Partially close PR if any of the line item is closed or issued from inventory
      closing_purchase_request_items = purchase_order.purchase_request_items.where(status_id: [PurchaseRequestItemStatus.id_for(:po_closed), PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:rejected)]).joins(:purchase_request).where('purchase_requests.purchase_request_status_id IN (?)', [PurchaseRequestStatus.id_for(:approved), PurchaseRequestStatus.id_for(:auto_approved), PurchaseRequestStatus.id_for(:partially_closed)]).where.not('purchase_requests.purchase_request_status_id = ?', PurchaseRequestStatus.id_for(:closed))
      if closing_purchase_request_items.present?
        closing_purchase_request_items.each do |purchase_request_item|
          purchase_request = purchase_request_item.purchase_request
          if purchase_request.approved? || purchase_request.auto_approved? || purchase_request.partially_closed?
            params[:document] = purchase_request
            params[:violation_present] = false
            if purchase_request.purchase_request_items.where.not(status_id: [PurchaseRequestItemStatus.id_for(:po_closed), PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:rejected)]).blank?
              params[:aasm_event] = 'close'
              op = WorkflowManager::Base.(user, params)
              unless op.success?
                add_message :error, "Cannot close associated purchase request #{purchase_request.order_number} at this state"
              end
            else
              params[:aasm_event] = 'partially_close'
              op = WorkflowManager::Base.(user, params)
              unless op.success?
                add_message :error, "Cannot partially close associated purchase request #{purchase_request.order_number} at this state"
              end
            end
          end
        end
      end
    end
  end

  def close_purchase_request_items
    if purchase_order.present? && purchase_order.purchase_request_items.present?
      if purchase_order.closed?
        purchase_order.purchase_request_items.where.not(status_id: PurchaseRequestItemStatus.id_for(:po_closed)).each do |purchase_request_item|
          purchase_request_item.update(status_id: PurchaseRequestItemStatus.id_for(:po_closed))
        end
      end
    end
  end

  def update_purchase_order_advance
    if purchase_order.advance_amount&.present? and purchase_order.advance_payments.blank?
      if purchase_order.advance_amount.value > 0
        purchase_order.advance_amount_status_id = AdvanceAmountStatus.id_for(:closed)
        purchase_order.save
      end
    end
  end
end