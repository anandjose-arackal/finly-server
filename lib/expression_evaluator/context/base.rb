class ExpressionEvaluator::Context::Base
  attr_accessor :data

  def initialize(data=nil)
    return nil unless self.class.accept?(data)

    self.data = data
  end

  def self.accept?(data=nil)
    true
  end

  def string_format(val)
    ExpressionEvaluator::Context::Fundamentals::String.new(val)
  end

  def integer_format(val)
    ExpressionEvaluator::Context::Fundamentals::Integer.new(val)
  end

end