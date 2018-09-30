class ExpressionEvaluator::Provider

  PROVIDERS = [
      ExpressionEvaluator::Context::Date,
      ExpressionEvaluator::Context::String
  ]

  def self.for(name)
    PROVIDERS.each do |provider|
      return provider.new if provider.method_defined?(name)
    end
    nil
  end

end