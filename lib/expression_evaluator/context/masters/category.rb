class ExpressionEvaluator::Context::Fundamentals::Category < ExpressionEvaluator::Context::Base

  alias_method :category, :data

  def self.accept?(data=nil)
    data and data.class.name == Category.name
  end

  def name(options={})
    string_format(data.name)
  end

end