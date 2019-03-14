class Procurements::PurchaseOrders::Reopen < Procurements::PurchaseOrders::Base
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
    # self.prev_status = self.purchase_order.trails.reverse.find {|t| [TrailAction.id_for(:auto_approve),
    #                                                                   TrailAction.id_for(:approve),
    #                                                                 TrailAction.id_for(:send_to_vendor)].include? t.action_id}

    
    status = (user.vendor_payment_admin? ? PurchaseOrderStatus.id_for(:auto_approved) : PurchaseOrderStatus.id_for(:approved))
    self.purchase_order.purchase_order_status_id = status

    unless self.purchase_order.save
      add_message :error, 'Unable to reopen purchase order. Please contact customer support.'
    end

  end

  def post_process
    # todo-olx
    # role_id = self.workflow_output[:role_id]
    # Event::EPurchaseOrder::Retract.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully Reopened Purchase Order'
  end
end