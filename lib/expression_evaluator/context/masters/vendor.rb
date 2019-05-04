class ExpressionEvaluator::Context::Masters::Vendor < ExpressionEvaluator::Context::Base

  alias_method :vendor, :data

  def self.accept?(data=nil)
    data and data.class.name == YesBankVendor.name
  end

  def vendor_type

  end

end