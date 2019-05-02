class Procurements::PurchaseOrders::MarkSendToVendor < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :workflow_output

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.procurement = self.purchase_order.procurement
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

  end

  def process
    # todo-abi
    # if purchase order's payment's been processed then should block voiding it
    params[:document] = self.purchase_order
    params[:aasm_event] = 'send_to_vendor'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
    end
    self.workflow_output = op.workflow_output

    # Update procurement send status
    status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_sent))
    unless procurement.status_tags.include? status_tag
      procurement.status_tags << status_tag
    end

    # todo release all the budgets #todo-sreeram
  end

  def post_process
    # Event::EPurchaseOrder::Reject.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully updated Purchase Order as send to vendor'
  end
end