class ExpressionEvaluator::Context::Documents::PurchaseOrder < ExpressionEvaluator::Context::Base

  alias_method :purchase_order, :data

  def self.accept?(data = nil)
    data and data.class.name == ::PurchaseOrder.name
  end

  def cost_center(options = {})
    self.purchase_order.cost_center
  end

  def department(options = {})
    self.purchase_order.department
  end

  def location(options = {})
    self.purchase_order.location
  end

end