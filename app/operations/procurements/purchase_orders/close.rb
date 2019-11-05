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
    update_purchase_request_status
  end

  def post_process
    add_message :success, 'Successfully Closed Purchase Order'
  end

  def update_purchase_request_status
    if purchase_order.purchase_request_items.present?
      if purchase_order.purchase_request_items.where.not(status_id: [PurchaseRequestItemStatus.id_for(:po_approved), PurchaseRequestItemStatus.id_for(:issued_from_inventory)]).blank?
        purchase_request = purchase_order&.purchase_request_items&.first&.purchase_request
        if purchase_request.present?
          params[:document] = purchase_request
          params[:aasm_event] = 'close'
          params[:violation_present] = false #todo Check violations
          op = WorkflowManager::Base.(user, params)
          unless op.success?
            add_message :error, "Cannot close associated purchase request at this state"
            return
          end
          close_purchase_request_items
        end
      end
    end
  end

  def close_purchase_request_items
    if purchase_order.present? && purchase_order.purchase_request_items.present?
      if purchase_order.closed?
        purchase_order.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(:po_closed))
      end
    end
  end
end