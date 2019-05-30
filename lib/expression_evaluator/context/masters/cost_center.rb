class ExpressionEvaluator::Context::Masters::CostCenter < ExpressionEvaluator::Context::Base

  alias_method :cost_center, :data

  def self.accept?(data=nil)
    data and data.class.name == ::CostCenter.name
  end

  def name(options={})
    cost_center.name
  end

  def code(options={})
    cost_center.cost_center_code
  end

  def to_s
    cost_center.name
  end

end