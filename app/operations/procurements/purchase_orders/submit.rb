class Procurements::PurchaseOrders::Submit < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    op = WorkflowManager::Base.(current_user, params)
    unless op.success?
      add_message :error, op.messages[:error]
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, 'Successfully submitted purchase order'

    Event::EPurchaseOrder::Submit.(user, {purchase_order: purchase_order, workflow_output: workflow_output})
  end
end