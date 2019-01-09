class Procurements::PurchaseOrders::Remind < Procurements::PurchaseOrders::Base
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

  end

  def post_process
    Event::EPurchaseOrder::Remind.(user, purchase_order: purchase_order)
    add_message :success, 'Successfully Sent Reminder Mail to Approver'
  end
end