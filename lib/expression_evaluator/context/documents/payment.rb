class ExpressionEvaluator::Context::Documents::Payment < ExpressionEvaluator::Context::Base

  alias_method :payment, :data

  def self.accept?(data=nil)
    data and data.class.name == Payment.name
  end

end