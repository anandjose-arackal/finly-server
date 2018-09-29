class Procurements::PurchaseOrders::Approve < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = PurchaseOrder.find_by id: purchase_order_id

    self.procurement = self.purchase_order&.procurement
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'approve'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    if purchase_order.approved? || purchase_order.auto_approved?
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_approved))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    Event::EPurchaseOrder::Approve.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully Approved Purchase Order'
  end
end