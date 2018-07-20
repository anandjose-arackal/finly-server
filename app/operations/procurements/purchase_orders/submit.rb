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
    params[:purchase_order] = self.purchase_order
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    op = WorkflowManager::PurchaseOrder.(current_user, params)
  end
end