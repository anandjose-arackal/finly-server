class ExpressionEvaluator::Context::Fundamentals::Integer < ExpressionEvaluator::Context::Base

  def self.accept?(data=nil)
    data and data.class.name == Integer.name
  end

end