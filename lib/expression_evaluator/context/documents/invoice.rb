class ExpressionEvaluator::Context::Documents::Invoice < ExpressionEvaluator::Context::Base

  alias_method :invoice, :data

  def self.accept?(data = nil)
    data and data.class.name == ::Invoice.name
  end

  def cost_center(options = {})
    self.invoice.cost_center
  end

  def department(options = {})
    self.invoice.department
  end

  def location(options = {})
    invoice.location
  end

end