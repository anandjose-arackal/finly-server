class ExpressionEvaluator::Provider

  PROVIDERS = [
      ExpressionEvaluator::Context::Fundamentals::Date,
      ExpressionEvaluator::Context::Fundamentals::String,
      ExpressionEvaluator::Context::Fundamentals::Integer,
      ExpressionEvaluator::Context::Documents::PurchaseRequest,
      ExpressionEvaluator::Context::Documents::PurchaseOrder,
      ExpressionEvaluator::Context::Documents::Invoice,
      ExpressionEvaluator::Context::Documents::Payment,
      ExpressionEvaluator::Context::Documents::PaymentTicket,
      ExpressionEvaluator::Context::Documents::GoodsReceiptNote,
      ExpressionEvaluator::Context::Masters::Category,
      ExpressionEvaluator::Context::Masters::ItemMaster,
      ExpressionEvaluator::Context::Masters::Vendor
  ]

  def self.for(name, data = nil)
    PROVIDERS.each do |provider|
      return provider.new(data) if provider.method_defined?(name) and provider.accept?(data)
    end
    nil
  end

end