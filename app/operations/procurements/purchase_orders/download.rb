class Procurements::PurchaseOrders::Download < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order

  def pre_validate
    if user.blank?
      add_message :error, 'Invalid parameters'
    end
  end

  def init
    id = params[:id] || params[:purchase_order_id]

    self.purchase_order = user.company.purchase_orders.find_by(id: id)
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase order not found"
      return
    end
  end

  def process

  end

  def success
    params[:purchase_order] = self.purchase_order
  end
end