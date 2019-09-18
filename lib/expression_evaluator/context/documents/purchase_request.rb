class ExpressionEvaluator::Context::Documents::PurchaseRequest < ExpressionEvaluator::Context::Base

  alias_method :purchase_request, :data

  def self.accept?(data=nil)
    data and data.class.name == ::PurchaseRequest.name
  end

  def cost_center(options={})
    self.purchase_request.cost_center
  end

  def department(options={})
    self.purchase_request.department
  end

  def location(options={})
    self.purchase_request.location
  end

end