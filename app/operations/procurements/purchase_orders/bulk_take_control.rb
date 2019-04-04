class Procurements::PurchaseOrders::BulkTakeControl < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders

  def init
    purchase_order_ids = params[:ids] || params[:purchase_order_ids]

    unless purchase_order_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    self.purchase_orders = user.company.purchase_orders.with_id(purchase_order_ids)
  end

  def validate
    if self.purchase_orders.empty?
      add_message :error, 'No Purchase Orders found'
    end
  end

  def process
    Procurements::PurchaseOrders::BulkTakeControlProcessor.call_async(user.id, {purchase_order_ids: purchase_orders.pluck(:id)})
  end

  def post_process
    add_message :success, "Taking control of multiple purchase orders (#{self.purchase_orders.length}). You will be notified via mail once all are done."
  end
end
