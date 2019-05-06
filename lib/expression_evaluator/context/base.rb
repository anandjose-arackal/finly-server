class ExpressionEvaluator::Context::Base
  attr_accessor :data

  def initialize(data=nil)
    return nil unless self.class.accept?(data)

    self.data = data
  end

  def self.accept?(data=nil)
    false
  end

  def send(method, options)
    return nil unless respond_to?(method)

    super(method, options)
  end

  def to_s
    data.to_s
  end

end