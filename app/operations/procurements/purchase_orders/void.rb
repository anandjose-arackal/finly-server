class Procurements::PurchaseOrders::Void < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    # unless InwardDocument.where(id: PurchaseOrder.find(1414).procurement_id).blank? && Invoice.where(id: PurchaseOrder.find(1414).procurement_id).blank?
    #   add_message :error, "Can't cancel a purchase order which has a GRN or Invoice attached."
    # end

    unless self.purchase_order.procurement.invoices.blank? && self.purchase_order.procurement.inward_documents.blank?
      add_message :error, "Can't cancel a purchase order which has a GRN or Invoice attached."
    end

  end

  def process
    # todo-abi
    # if purchase order's payment's been processed then should block voiding it
    params[:document] = self.purchase_order
    params[:aasm_event] = 'void'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.workflow_output = op.workflow_output

    # todo release all the budgets #todo-sreeram
    update_purchase_request_status
  end

  def post_process
    Event::EPurchaseOrder::Reject.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully Voided Purchase Order'
  end

  def update_purchase_request_status
    if self.purchase_order.purchase_request_items.present?
      self.purchase_order.purchase_request_items.each do |purchase_request_item|
        purchase_request = purchase_request_item.purchase_request
        unless purchase_request.approved? || purchase_request.auto_approved?
          if purchase_request.purchase_request_items.where.not(id: self.purchase_order.purchase_request_items.pluck(:id)).where(status_id: PurchaseRequestItemStatus.id_for(:po_closed)).blank?
            params[:document] = purchase_request
            params[:aasm_event] = 'po_void'
            params[:violation_present] = false
            op = WorkflowManager::Base.(user, params)
            unless op.success?
              add_message :error, op.messages[:error]
              return
            end
          end
        end
        purchase_request_item.update_attributes(purchase_order_id: nil, status_id: PurchaseRequestItemStatus.id_for(:approved))
        Trail.create(parent_type: 'PurchaseRequestItem', parent_id: purchase_request_item.id, action_user_id: user.id, action_id: TrailAction.id_for(:po_void))
      end
    end
  end
end