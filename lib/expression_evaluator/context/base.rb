class ExpressionEvaluator::Context::Base
  attr_accessor :data

  def initialize(data=nil)
    self.data = data
  end

end