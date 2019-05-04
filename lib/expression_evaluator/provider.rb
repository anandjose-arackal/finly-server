class ExpressionEvaluator::Provider

  PROVIDERS = [
      ExpressionEvaluator::Context::Date,
      ExpressionEvaluator::Context::String,
      ExpressionEvaluator::Context::PurchaseRequest
  ]

  def self.for(name, data = nil)
    PROVIDERS.each do |provider|
      return provider.new(data) if provider.method_defined?(name) and provider.accept?(data)
    end
    nil
  end

end