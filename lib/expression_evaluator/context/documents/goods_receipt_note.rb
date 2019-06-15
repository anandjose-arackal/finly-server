class ExpressionEvaluator::Context::Documents::GoodsReceiptNote < ExpressionEvaluator::Context::Base

  alias_method :grn, :data

  def self.accept?(data = nil)
    data and data.class.name == InwardDocument.name
  end

  def cost_center(options = {})
    self.purchase_order.cost_center
  end

  def department(options = {})
    purchase_order.department
  end

  def location(options = {})
    self.purchase_order.location
  end

  protected

  def purchase_order
    self.grn&.procurement&.purchase_order
  end

end