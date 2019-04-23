# this operation is the reverse of take control, in the sense that it return control to whoever the person
# was from whom control was taken
class Procurements::PurchaseOrders::ReturnControl < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    # todo scope it and in all similar places
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id

    self.procurement = self.purchase_order&.procurement
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase Order not found"
      return
    end

    unless user.vendor_payment_admin?
      add_message :error, "Only admins can return control of an purchase order."
      return
    end

    unless purchase_order.can_return_control?
      add_message :error, "Purchase Order cannot be return controlled of at this stage"
      return
    end
  end


  def process
    params[:document] = self.purchase_order
    params[:aasm_event] = 'return_control'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # Event::EPurchaseOrder::ReturnControl.(user, purchase_order: purchase_order, workflow_output: workflow_output)

    add_message :success, "Administrative control of Purchase Order sucessfully removed."
  end


end