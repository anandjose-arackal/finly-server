class Procurements::PurchaseOrders::Reject < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'reject'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
    end
    self.workflow_output = op.workflow_output
  end

  def post_process
    # todo-olx
    Event::EPurchaseOrder::Reject.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully Rejected Purchase Order'
  end
end